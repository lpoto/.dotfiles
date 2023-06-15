---@class LogUtil
---@field title string?
---@field delay number?
local Log = {}
Log.__index = Log

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
  self:__notify("error", self.title, self.delay, true, ...)
end

---@param delay number?: Delay in milliseconds, default: 0
---@param title string?: Title of the notification
---@return LogUtil
function Log:new(delay, title)
  local o = {}
  if type(title) == "string" then
    o.title = title
  end
  if type(delay) == "number" then
    o.delay = delay
  end
  return setmetatable(o, Log)
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
