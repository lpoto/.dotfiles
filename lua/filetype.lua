--============================================================================= -----------------------------------------------------------------------------
--                                                                     FILETYPE
--=============================================================================
-- A Filetype object that stores config for the filetype. The config's filetype
-- matches the current filetype, so this works best in ftplugin/ .
--
-- If the Filetype object's config was already loaded, it will not be loaded
-- again, except it's `always` function.
--
-- Filetype objects may then be fetches, and disabled or overriden. Useful
-- for project-local configs.
--_____________________________________________________________________________

local log = require "log"
local Plugin = require "plugin"

local created = {}
local disabled = {}

---@class Filetype
---@field always function?: A function run every time the filetype is oppened.
---@field init function?: A config run the first time the filetype is oppened.
---@field formatter function|table|nil: Formatter.nvim's formatter config function
---or a table of functions.
---@field lsp_server table|string?: A lspconfig's server config
---(server name on index 1 and optional config on 2, or just server name),
---cmp capabilities will be automatically added.
---@field linter string|table|nil: A nvim-lint linter name or a table of liner names.
---@field copilot boolean?: Whether to start copilot or not.
---@field actions table?: A table of Actions.nvim actions
local Filetype = {
  __loaded = false,
  __disabled = false,
  __filetype = nil,
}
Filetype.__index = Filetype

---Create a new Filetype config. It may then be fetched
---with `Filetype.get(filetype)`. Filetype will be automatically determined
---with `vim.bo.filetype` unless it is provided.
---
---If a filetype config was already created for the current filetype,
---this will return that config instead.
---
---@param o Filetype: A filetype config
---@param filetype string?: A filetype (optional)
---@return Filetype
function Filetype.new(o, filetype)
  local cfg = {}
  setmetatable(cfg, Filetype)

  if filetype == nil then
    cfg.__filetype = vim.bo.filetype
  else
    cfg.__filetype = filetype
  end

  if disabled[cfg.__filetype] then
    cfg.__disabled = true
  end

  local cfg2 = created[cfg.__filetype]
  if cfg2 ~= nil then
    return cfg2
  end
  created[cfg.__filetype] = cfg

  for k, v in pairs(o) do
    if k == "init" then
      assert(type(v) == "function")
      cfg.init = v
    elseif k == "always" then
      assert(type(v) == "function")
      cfg.always = v
    elseif k == "formatter" then
      assert(
        type(v) == "function"
          or type(v) == "table" and type(v[1]) == "function"
      )
      cfg.formatter = v
    elseif k == "copilot" then
      assert(type(v) == "boolean")
      cfg.copilot = v
    elseif k == "linter" then
      assert(
        type(v) == "table" and type(v[1]) == "string" or type(v) == "string"
      )
      if type(v) == table then
        cfg.linter = v
      else
        cfg.linter = { v }
      end
    elseif k == "lsp_server" then
      assert(
        type(v) == "table"
            and type(
              v[1] == "string" and (v[2] == nil or type(v[2]) == "table")
            )
          or type(v) == "string"
      )
      cfg.lsp_server = v
    elseif k == "actions" then
      assert(type(v) == "table")
      cfg.actions = v
    else
      log.warn("Invalid filetype field: " .. k)
    end
  end

  return cfg
end

---Load the Filetype config. If the filetype is disabled, this
---will be a no-op.
---Similar id the config was already loaded, except that
---the `always` function will run.
function Filetype:load()
  if self.__disabled == true then
    return
  end

  if self.always ~= nil then
    self.always()
  end

  if self.__loaded == true then
    return
  end

  self.__loaded = true

  if self.init ~= nil then
    self.init()
  end

  if self.formatter ~= nil and Plugin.exists "formatter" then
    Plugin.get("formatter"):config(function()
      local formatter = require "formatter"
      formatter.setup {
        filetype = {
          [self.__filetype] = self.formatter,
        },
      }
    end)
  end

  if self.copilot == true and Plugin.exists "copilot" then
    Plugin.get("copilot"):run("enable", self.__filetype)
  end

  if self.linter ~= nil and Plugin.exists "lint" then
    Plugin.get("lint"):config(function()
      local lint = require "lint"
      if lint.linters_by_ft == nil then
        lint.linters_by_ft = {}
      end
      lint.lines_by_ft[self.__filetype] = self.linter
    end)
  end

  if self.lsp_server ~= nil and Plugin.exists "lspconfig" then
    Plugin.get("lspconfig"):config(function()
      local lspconfig = require "lspconfig"
      local log = require "log"

      local server
      local opt = {}
      if type(self.lsp_server) == "table" then
        server = self.lsp_server[1]
        opt = self.lsp_server[2] or {}
      else
        server = self.lsp_server
      end
      if opt.capabilities == nil and Plugin.exists "cmp" then
        opt.capabilities = require("cmp_nvim_lsp").default_capabilities()
      end
      if lspconfig[server] == nil then
        log.warn("LSP server not found: " .. server)
        return
      end
      local l = lspconfig[server]
      if l == nil then
        log.warn("LSP server not found: " .. server)
        return
      end
      l.setup(opt)
    end)
    vim.fn.execute("LspStart", true)
  end

  if self.actions ~= nil and Plugin.exists "actions" then
    Plugin.get("actions"):config(function()
      local actions = require "actions"
      actions.setup {
        actions = self.actions,
      }
    end)
  end
end

---Get a Filetype config. If the config was not created yet,
---this will return nil.
---
---@param filetype string: A filetype
---@return Filetype
function Filetype.get(filetype)
  return created[filetype]
end

---Disable the filetype config.
---@param filetype string?: A filetype, otherwise `vim.bo.filetype` will be used.
function Filetype.disable(filetype)
  if filetype == nil then
    filetype = vim.bo.filetype
  end
  if created[filetype] ~= nil then
    created[filetype].__disabled = true
  end
  disabled[filetype] = true
end

return Filetype
