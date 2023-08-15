--=============================================================================
-------------------------------------------------------------------------------
--                                                                         UTIL
--[[===========================================================================
Util functions
-----------------------------------------------------------------------------]]
---@class Util
local util = {}
util.__index = util

---@return FtpluginUtil
function util.ftplugin()
  return util.require("util.ftplugin") --[[ @as FtpluginUtil ]]
end

---@return PathUtil
function util.path()
  return util.require("util.path") --[[ @as PathUtil ]]
end

---@return ShellUtil
function util.shell()
  return util.require("util.shell") --[[ @as ShellUtil ]]
end

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
  vim.fn.stdpath = util.path().stdpath
  self.log():set_level(opts.log_level)
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
      util.log():warn("module must be a string or table")
    end
  end
  local res = {}
  for _, m in ipairs(module) do
    local ok, v = pcall(require, m)
    if not ok then
      if not silent then
        util.log({ delay = 250 }):warn("Error loading", m, "-", v)
      end
      return
    end
    table.insert(res, v)
  end
  if type(callback) == "function" then
    local ok, v = pcall(callback, unpack(res))
    if not ok then
      if not silent then
        util.log({ delay = 250 }):error(v)
      end
      return
    end
    return v
  end
  return unpack(res)
end

---@param s1 string
---@param s2 string
function util.string_matching_score(s1, s2)
  if type(s1) ~= "string" or type(s2) ~= "string" then
    return 0
  end
  local score = 0
  for i = 1, s2:len() do
    local c1 = s2:sub(i, i)
    for j = 1, s1:len() do
      local c2 = s1:sub(j, j)
      if c1 == c2 then
        local add = math.max(1, 5 - i)
        score = score + add
        break
      end
    end
  end
  return score
end

return util
