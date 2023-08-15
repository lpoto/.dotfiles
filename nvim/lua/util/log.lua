---@class LogUtil
---@field title string?
---@field delay number?
---@field level LogLevelValue?
local Log = {}
Log.__index = Log

---@alias LogLevelValue number

---@class LogLevel
---@field DEBUG LogLevelValue
---@field INFO LogLevelValue
---@field WARN LogLevelValue
---@field ERROR LogLevelValue
Log.Level = {
  TRACE = 0,
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
}

---@param level LogLevelValue|'TRACE'|'DEBUG'|'INFO'|'WARN'|'ERROR'
function Log:set_level(level)
  if type(level) == "string" then
    level = Log.Level[level:upper()] or Log.Level.INFO
  end
  Log.level = level
end

function Log:trace(...)
  self:__notify("trace", self.title, self.delay, false, ...)
end

function Log:debug(...)
  self:__notify("debug", self.title, self.delay, false, ...)
end

function Log:info(...)
  self:__notify("info", self.title, self.delay, false, ...)
end

function Log:warn(...)
  self:__notify("warn", self.title, self.delay, false, ...)
end

function Log:error(...)
  self:__notify("error", self.title, self.delay, false, ...)
end

function Log:print(...)
  self:__notify("info", self.title, self.delay, true, ...)
end

---@param opts table|number|string|nil
---@return LogUtil
function Log:new(opts)
  if type(opts) == "number" then
    opts = { level = opts }
  elseif type(opts) == "string" then
    opts = { title = opts }
  elseif type(opts) ~= "table" then
    opts = {}
  end
  return setmetatable(opts, Log)
end

local function concat(...)
  local s = ""
  for _, v in ipairs({ select(1, ...) }) do
    if type(v) ~= "string" then
      v = vim.inspect(v)
    end
    if s:len() > 0 then
      s = s .. " " .. v
    else
      s = v
    end
  end
  return s
end

---@private
function Log:__notify(level, title, delay, use_print, ...)
  local lvl = Log.Level[level:upper()]
  local log_lvl = type(self.level) == "number" and self.level
    or Log.Level.INFO
  if lvl < log_lvl then
    return
  end

  local msg = concat(...)
  if use_print then
    return print(msg)
  end
  delay = delay or 0
  local n = debug.getinfo(3)

  if type(n) == "table" and type(title) ~= "string" then
    if type(n.short_src) == "string" then
      title = vim.fn.fnamemodify(n.short_src, ":t")
    end
    local s = ""
    if type(n.name) == "string" then
      s = n.name
    end
    if type(n.currentline) == "number" then
      s = s .. ":" .. n.currentline
    end
    if s:len() > 0 then
      if type(title) ~= "string" or title:len() == 0 then
        title = s
      else
        title = title .. " (" .. s .. ")"
      end
    end
  end

  vim.defer_fn(function()
    if msg:len() > 0 then
      vim.notify(msg, level, {
        title = title,
      })
    end
  end, delay)
end

return Log
