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

local ftplugins_loaded = {}
---@private
function util.__init_ftplugin()
  vim.api.nvim_create_autocmd("Filetype", {
    callback = function(opts)
      if
        vim.bo.buftype ~= ""
        or type(opts) ~= "table"
        or type(opts.match) ~= "string"
      then
        return
      end
      local filetype = opts.match
      if ftplugins_loaded[filetype] then
        return
      end
      ftplugins_loaded[filetype] = true

      local formatter = vim.g[filetype .. "_formatter"] or vim.b.formatter
      local linter = vim.g[filetype .. "_linter"] or vim.b.linter
      local language_server = vim.g[filetype .. "_language_server"]
        or vim.b.language_server
      if formatter ~= nil then
        util.misc().attach_formatter(formatter, filetype)
        vim.g[filetype .. "_formatter"] = nil
        vim.b.formatter = nil
      end
      if linter ~= nil then
        util.misc().attach_linter(linter, filetype)
        vim.g[filetype .. "_linter"] = nil
        vim.b.linter = nil
      end
      if language_server ~= nil then
        util.misc().attach_language_server(language_server)
        vim.g[filetype .. "_language_server"] = nil
        vim.b.language_server = nil
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
