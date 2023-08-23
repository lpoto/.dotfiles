--=============================================================================
-------------------------------------------------------------------------------
--                                                                         UTIL
--[[===========================================================================
Util functions
-----------------------------------------------------------------------------]]
---@class Util
local util = {}
util.__index = util

---@param opts table|string|number|nil
---@return LogUtil
function util.log(opts)
  return util.require("util.log"):new(opts) --[[ @as LogUtil ]]
end

---@return MiscUtil
function util.misc()
  return util.require("util.misc") --[[ @as MiscUtil ]]
end

---@param opts {log_level:LogLevelValue|'TRACE'|'DEBUG'|'INFO'|'WARN'|'ERROR'}
---@return Util
function util:init(opts)
  opts = type(opts) == "table" and opts or {}
  self.log():set_level(opts.log_level)
  vim.fn.stdpath = self.stdpath
  self.__init_ftplugin()
  return self
end

--- catch errors from require and display them in a notification,
--- so multiple modules may be loaded even if one fails
---
--- Callback will be called only if all modules are loaded successfully.
---
--- @param module string|table
--- @param callback function?
--- @param silent boolean?
function util.require(module, callback, silent)
  if type(module) == "string" then
    module = { module }
  elseif type(module) ~= "table" then
    if not silent then
      util.log("Util"):warn("[require] module must be a string or table")
    end
  end
  local res = {}
  for _, m in ipairs(module) do
    local ok, v = pcall(require, m)
    if not ok then
      if not silent then
        util
          .log({ delay = 250, title = "Util" })
          :warn("[require] Error loading", m, "-", v)
      end
      return
    end
    table.insert(res, v)
  end
  if type(callback) == "function" then
    local ok, v = pcall(callback, unpack(res))
    if not ok then
      if not silent then
        util.log({ delay = 250, title = "Util" }):error("[require]", v)
      end
      return
    end
    return v
  end
  return unpack(res)
end

local ftplugins_loaded = {}
---@private
function util.__init_ftplugin()
  vim.api.nvim_create_autocmd("Filetype", {
    callback = function(opts)
      if
        vim.bo.buftype ~= ""
        or type(opts) ~= "table"
        or type(opts.match) ~= "string"
        or type(opts.buf) ~= "number"
        or not vim.api.nvim_buf_is_valid(opts.buf)
      then
        return
      end
      local filetype = opts.match
      if ftplugins_loaded[filetype] then return end
      ftplugins_loaded[filetype] = true

      local ok, formatter = true, vim.g[filetype .. "_formatter"]
      if formatter == nil then
        ok, formatter = pcall(vim.api.nvim_buf_get_var, opts.buf, "formatter")
      end
      if ok and formatter ~= nil then
        util.misc().attach_formatter(formatter, filetype)
        vim.g[filetype .. "_formatter"] = nil
        vim.api.nvim_buf_del_var(opts.buf, "formatter")
      end
      local linter
      ok, linter = true, vim.g[filetype .. "_linter"]
      if linter == nil then
        ok, linter = pcall(vim.api.nvim_buf_get_var, opts.buf, "linter")
      end
      if ok and linter ~= nil then
        util.misc().attach_linter(linter, filetype)
        vim.g[filetype .. "_linter"] = nil
        vim.api.nvim_buf_del_var(opts.buf, "linter")
      end
      local language_server
      ok, language_server = true, vim.g[filetype .. "_language_server"]
      if language_server == nil then
        ok, language_server =
          pcall(vim.api.nvim_buf_get_var, opts.buf, "language_server")
      end
      if ok and language_server ~= nil then
        util.misc().attach_language_server(language_server)
        vim.g[filetype .. "_language_server"] = nil
        vim.api.nvim_buf_del_var(opts.buf, "language_server")
      end
    end,
  })
end

local stdpath = vim.fn.stdpath
---@param what string
---@return string|table
function util.stdpath(what)
  local app_name = os.getenv("NVIM_APPNAME")
  if type(app_name) ~= "string" or app_name:len() == 0 then
    app_name = "nvim"
  end
  local base = vim.fs.dirname(stdpath("config"))
  local storage = base .. "/.storage"

  local n = {
    config = base .. "/" .. app_name,
    app_name,
    cache = storage .. "/cache/" .. app_name,
    data = storage .. "/share/" .. app_name,
    log = storage .. "/log/" .. app_name,
    run = storage .. "/state/" .. app_name,
    state = storage .. "/state/" .. app_name,
    config_dirs = {},
    data_dirs = {},
  }
  return n[what] or stdpath(what)
end

return util
