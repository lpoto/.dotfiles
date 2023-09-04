--=============================================================================
-------------------------------------------------------------------------------
--                                                                       NOTIFY
--[[===========================================================================
-- Override the default vim.notify implementation
-----------------------------------------------------------------------------]]

local concat

local notify = vim.notify
---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, opts)
  if type(msg) == "table" then
    msg = concat(unpack(msg))
  else
    msg = concat(msg)
  end
  if type(level) == "string" then level = vim.log.levels[level:upper()] end
  if
    type(level) ~= "number"
    or level < vim.log.levels.TRACE
    or level > vim.log.levels.OFF
  then
    level = vim.log.levels.INFO
  end
  if type(opts) == "string" then opts = { title = opts } end
  if type(opts) ~= "table" then opts = {} end
  if type(opts.title) == "string" then
    msg = "[" .. opts.title .. "] " .. msg
  end
  local delay = 0
  if type(opts.delay) == "number" and opts.delay > 0 then
    delay = opts.delay
    opts.delay = nil
  end

  vim.defer_fn(function() notify(msg, level, opts) end, delay)
end

function concat(...)
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
