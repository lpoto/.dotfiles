---@class LogUtil
---@field title string?
---@field delay number?
---@field level 0|1|2|3|4
local Log = {}
Log.__index = Log

---@param level 0|1|2|3|4
function Log:set_level(level)
  if type(level) ~= "number" then level = vim.log.levels.DEBUG end
  Log.level = level
end

function Log:trace(...)
  self:__notify(vim.log.levels.TRACE, self.title, self.delay, false, ...)
end

function Log:debug(...)
  self:__notify(vim.log.levels.DEBUG, self.title, self.delay, false, ...)
end

function Log:info(...)
  self:__notify(vim.log.levels.INFO, self.title, self.delay, false, ...)
end

function Log:warn(...)
  self:__notify(vim.log.levels.WARN, self.title, self.delay, false, ...)
end

function Log:error(...)
  self:__notify(vim.log.levels.ERROR, self.title, self.delay, false, ...)
end

function Log:print(...)
  self:__notify(vim.log.levels.INFO, self.title, self.delay, true, ...)
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
  if type(opts.title) ~= "string" and type(opts.name) == "string" then
    opts.title = opts.name
  end
  return setmetatable(opts, Log)
end

local function concat(...)
  local s = ""
  for _, v in ipairs({ select(1, ...) }) do
    if type(v) ~= "string" then v = vim.inspect(v) end
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
  local log_lvl = type(self.level) == "number" and self.level
    or vim.log.levels.DEBUG
  if type(level) ~= "number" then level = vim.log.levels.INFO end
  if level < log_lvl then return end

  local msg = concat(...)
  if use_print then return print(msg) end
  delay = delay or 0
  local n = debug.getinfo(3)

  if type(n) == "table" and type(title) ~= "string" then
    if type(n.short_src) == "string" then
      title = vim.fn.fnamemodify(n.short_src, ":t")
    end
    local s = ""
    if type(n.name) == "string" then s = n.name end
    if type(n.currentline) == "number" then s = s .. ":" .. n.currentline end
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

local notify = vim.notify
---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, opts)
  if type(opts) == "string" then
    opts = { title = opts }
  elseif type(opts) ~= "table" then
    opts = {}
  end
  if type(msg) ~= "string" then msg = vim.inspect(msg) end
  if type(opts.title) == "string" then
    msg = "[" .. opts.title .. "] " .. msg
  end
  notify(msg, level, opts)
end

return Log
