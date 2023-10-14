--=============================================================================
-------------------------------------------------------------------------------
--                                                                       NOTIFY
--[[===========================================================================
-- Override the default vim.notify implementation
-----------------------------------------------------------------------------]]

local apply_arguments

local notify = vim.notify
---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, opts)
  if msg == nil or type(msg) == 'string' and msg:len() == 0 then return end
  if type(msg) ~= 'string' then msg = vim.inspect(msg) end
  if type(level) == 'string' then level = vim.log.levels[level:upper()] end
  if
    type(level) ~= 'number'
    or level < vim.log.levels.TRACE
    or level > vim.log.levels.OFF
  then
    level = vim.log.levels.INFO
  end
  if type(opts) == 'string' then opts = { title = opts } end
  if type(opts) ~= 'table' then opts = {} end
  if type(opts.title) == 'string' then
    if opts.title:len() > 0 then msg = '[' .. opts.title .. '] ' .. msg end
    opts.title = nil
  end
  local delay = 0
  if type(opts.delay) == 'number' then
    if opts.delay > 0 then delay = opts.delay end
    opts.delay = nil
  end
  msg = apply_arguments(msg, opts.args)
  opts.args = nil

  vim.defer_fn(function() notify(msg, level, opts) end, delay)
end

function apply_arguments(msg, args)
  if type(args) ~= 'table' or #args == 0 then return msg end
  for _, arg in ipairs(args) do
    -- gsub {} with arg in string
    msg = msg:gsub('{}', function()
      if type(arg) == 'string' then return arg end
      return vim.inspect(arg)
    end, 1)
  end
  return msg
end
