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
