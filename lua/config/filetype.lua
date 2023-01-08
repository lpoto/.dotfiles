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

local configs = {}

local M = {}

---@param o table: A config object:
---  A config object may contain the following fields:
---    - `filetype` (string|nil): The filetype to load the config for. If not provided, the current filetype will be used. All of the following fields relate to this filetype.
---    - `priority` (number): The priority of the config. Filetype config fields with the highest priority will be loaded (default: 1).
---    - `formatter` (string): The formatter to use. Should be one of null-ls's builtin formatters.
---    - `language_server` (table|string|nil): A lspconfig's server config (server name on index 1 and optional config on 2, or just server name), cmp capabilities will be automatically added.
---    - `linter` (string|table|nil): A liter name. Should be one of null-ls's diagnostics.
---    - `copilot` (boolean|nil): Whether to start copilot for the filetype or not.
---    - `actions` (table|nil): A table of Actions.nvim actions.
---    - `debugger` (table|nil): A table for a dap.nvim debugger config, with fields `adapters` and `configurations` (see dap.nvim's docs).
---    - `unset` (table|nil): A table of fields to unset. This is useful for project-local configs, to unset some fields from the global config.
---
---  It would be useful to use multiple config when you want to set some fields with higher priority than others.
---  Priority makes sense when defining multiple configs for the same filetype, especially in local configs.
---
---  To load a config for a filetype, use `Filetype.load(<filetype>)`. If the filetype is not provided, the current filetype will be used.
---  NOTE: once a config for filetype is loaded, no configs may be added.
---
---<code>
---  filetype.config {
---    priority = 10,
---    filetype = "python",
---    language_server = "pyslp",  -- could also use { "pyslp", { ... options } }
---  }
---  filetype.config {
---    priority = 5,
---    filetype = "python",
---    lint = "flake8",
---    copilot = true,
---    unset = {"debugger", "actions"}
---  }
---</code>
function M.config(o)
  local ok, e = pcall(function()
    o = o or {}

    local filetype = o.filetype or vim.bo.filetype
    local priority = o.priority or 1

    if
      configs[filetype]
      and (configs[filetype].disabled or configs[filetype].loaded)
    then
      return
    end

    local types = {
      priority = { "number" },
      filetype = { "string" },
      formatter = { "string" },
      language_server = { "table", "string" },
      linter = { "string" },
      copilot = { "boolean" },
      actions = { "table" },
      debugger = { "table" },
      unset = { "table", "string" },
    }

    if configs[filetype] == nil then
      configs[filetype] = {
        priorities = {},
        values = {},
      }
    end
    for k, v in pairs(o) do
      if types[k] == nil then
        vim.notify(
          "Unknown filetype config field: " .. k,
          vim.log.levels.WARN
        )
      elseif not vim.tbl_contains(types[k], type(v)) then
        vim.notify(
          "Invalid filetype config field: " .. k,
          vim.log.levels.WARN
        )
      elseif k == "unset" then
        for _, k2 in ipairs(v) do
          if types[k2] == nil then
            vim.notify(
              "Unknown filetype config field: " .. k2,
              vim.log.levels.WARN
            )
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
  end)
  if ok == false then
    vim.notify(
      "Error while loading filetype config: " .. e,
      vim.log.levels.ERROR
    )
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
  vim.defer_fn(function()
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
        if k == "formatter" then
          require("plugins.null-ls").register_builtin_source(
            "formatting",
            v,
            filetype
          )
        elseif k == "copilot" and v == true then
          require("plugins.copilot").enable(filetype)
        elseif k == "linter" then
          require("plugins.null-ls").register_builtin_source(
            "diagnostics",
            v,
            filetype
          )
        elseif k == "language_server" then
          require("plugins.lspconfig").add_language_server(v)
        elseif k == "actions" then
          vim.g.telescope_tasks =
            vim.tbl_extend("force", vim.g.telescope_tasks or {}, v)
        elseif k == "debugger" then
          require("plugins.dap").add_adapters(v.adapters)
          require("plugins.dap").add_configurations(
            v.configurations,
            filetype
          )
        end
      end
    end)
    if ok == false then
      vim.notify(
        "Error while loading filetype config: " .. e,
        vim.log.levels.ERROR
      )
    end
  end, 100)
end

return M
