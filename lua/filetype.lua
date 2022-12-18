--============================================================================= -----------------------------------------------------------------------------
--                                                                     FILETYPE
--=============================================================================
-- A Filetype object that stores config for the filetype. The config's filetype
-- matches the current filetype, so this works best in ftplugin/ .
--
-- If the Filetype object's config was already loaded, it will not be reloaded.
--
-- Filetype objects may then be fetches, and disabled or overriden. Useful
-- for project-local configs.
--_____________________________________________________________________________

local log = require "log"
local Plugin = require "plugin"

local configs = {}

local M = {}

---@param o table: A config object, or a table of config objects.
---  A config object may contain the following fields:
---    - `filetype` (string|nil): The filetype to load the config for. If not provided, the current filetype will be used. All of the following fields relate to this filetype.
---    - `priority` (number): The priority of the config. Filetype config fields with the highest priority will be loaded (default: 1).
---    - `formatter` (function|table|nil): Formatter.nvim's formatter config function or a table of functions.
---    - `lsp_server` (table|string|nil): A lspconfig's server config (server name on index 1 and optional config on 2, or just server name), cmp capabilities will be automatically added.
---    - `linter` (string|table|nil): A nvim-lint linter name or a table of liner names.
---    - `copilot` (boolean|nil): Whether to start copilot for the filetype or not.
---    - `actions` (table|nil): A table of Actions.nvim actions.
---    - `debugger` (table|nil): A table for a dap.nvim debugger config, with fields `adapters` and `configurations` (see dap.nvim's docs).
---    - `unset` (table|nil): A table of fields to unset. This is useful for project-local configs, to unset some fields from the global config.
---
---  It would be useful to pass multiple objects when you want to set some fields with higher priority than others.
---  Priority makes sense when defining multiple configs for the same filetype, especially in local configs.
---
---  To load a config for a filetype, use `Filetype.load(<filetype>)`. If the filetype is not provided, the current filetype will be used.
---
---<code>
---  filetype.config {
---    {
---      priority = 10,
---      filetype = "python",
---      lsp_server = "pyslp",  -- could also use { "pyslp", { ... options } }
---    },
---    {
---      priority = 5,
---      filetype = "python",
---      lint = "flake8",  -- could define multiple linters: { "flake8", "pylint" }
---      copilot = true,
---      unset = {"debugger", "actions"}
---    }
---  }
---</code>
function M.config(o)
  local ok, e = pcall(function()
    if o[1] == nil then
      o = { o }
    end

    local types = {
      priority = { "number" },
      filetype = { "string" },
      formatter = { "function", "table" },
      lsp_server = { "table", "string" },
      linter = { "string", "table" },
      copilot = { "boolean" },
      actions = { "table" },
      debugger = { "table" },
      unset = { "table", "string" },
    }

    for _, opt in ipairs(o) do
      local filetype = opt.filetype or vim.bo.filetype
      local priority = opt.priority or 1

      if configs[filetype] == nil then
        configs[filetype] = {
          priorities = {},
          values = {},
        }
      end
      for k, v in pairs(opt) do
        if types[k] == nil then
          log.warn("Unknown filetype config field: " .. k)
        elseif not vim.tbl_contains(types[k], type(v)) then
          log.warn("Invalid filetype config field: " .. k)
        elseif k == "unset" then
          for _, k2 in ipairs(v) do
            if types[k2] == nil then
              log.warn("Unknown filetype config field: " .. k2)
            else
              -- Keep priorities, only unset values
              configs[filetype].values[k2] = nil
              if configs[filetype].priorities[k2] == nil then
                configs[filetype].priorities[k2] = priority
              end
            end
          end
        elseif
          configs[filetype].priorities[k] == nil
          or priority > configs[filetype].priorities[k]
        then
          configs[filetype].priorities[k] = priority
          configs[filetype].values[k] = v
        end
      end
    end
  end)
  if ok == false then
    log.warn("Error while loading filetype config: " .. e)
  end
end

---Disable the config for the provided filetype, or the current filetype if none is provided.
---This is useful for project-local configs, where we would want to disable config
---for a specific filetype.
---@param filetype string|nil
function M.disable(filetype)
  filetype = filetype or vim.bo.filetype
  assert(type(filetype) == "string")

  if configs[filetype] == nil then
    configs[filetype] = {
      priorities = {},
      values = {},
    }
  end
  configs[filetype].disabled = true
end

---Load the config for the provided filetype, or the current filetype if none is provided.
---@param filetype string|nil
function M.load(filetype)
  local ok, e = pcall(function()
    filetype = filetype or vim.bo.filetype

    if
      configs[filetype] == nil
      or configs[filetype].values == nil
      or configs[filetype].disabled
      or configs[filetype].loaded
    then
      return
    end

    configs[filetype].loaded = true

    for k, v in pairs(configs[filetype].values) do
      if k == "formatter" and Plugin.exists "formatter" then
        Plugin.get("formatter"):config(function()
          local formatter = require "formatter"
          formatter.setup {
            filetype = {
              [filetype] = v,
            },
          }
        end)
      elseif k == "copilot" and v == true and Plugin.exists "copilot" then
        Plugin.get("copilot"):run("enable", filetype)
      elseif k == "linter" and Plugin.exists "lint" then
        Plugin.get("lint"):config(function()
          local lint = require "lint"
          if lint.linters_by_ft == nil then
            lint.linters_by_ft = {}
          end
          if type(v) == "string" then
            v = { v }
          end
          assert(type(filetype) == "string")
          lint.linters_by_ft[filetype] = v
        end)
        require "lint"
      elseif k == "lsp_server" and Plugin.exists "lspconfig" then
        Plugin.get("lspconfig"):config(function()
          local lspconfig = require "lspconfig"
          local lg = require "log"

          local server
          local opt = {}
          if type(v) == "table" then
            server = v[1]
            opt = v[2] or {}
          else
            server = v
          end
          if opt.capabilities == nil and Plugin.exists "cmp" then
            opt.capabilities = require("cmp_nvim_lsp").default_capabilities()
          end
          if lspconfig[server] == nil then
            lg.warn("LSP server not found: " .. server)
            return
          end
          local lsp = lspconfig[server]
          if lsp == nil then
            lg.warn("LSP server not found: " .. server)
            return
          end
          lsp.setup(opt)
        end)
        local ok, e = pcall(vim.fn.execute, "LspStart", true)
        if ok == false then
          log.warn("Failed to start LSP: " .. e)
        end
      elseif k == "actions" and Plugin.exists "actions" then
        Plugin.get("actions"):config(function()
          local actions = require "actions"
          actions.setup {
            actions = v,
          }
        end)
      elseif k == "debugger" and Plugin.exists "dap" then
        Plugin.get("dap"):config(function()
          local dap = require "dap"
          if v.adapters ~= nil then
            for k2, v2 in pairs(v.adapters) do
              dap.adapters[k2] = v2
            end
          end
          if v.configurations[1] == nil then
            for k2, v2 in pairs(v.configurations) do
              dap.configurations[k2] = v2
            end
          else
            assert(type(filetype) == "string")
            dap.configurations[filetype] = v.configurations
          end
        end)
      end
    end
  end)
  if ok == false then
    log.warn("Error while loading filetype config: " .. e)
  end
end

return M
