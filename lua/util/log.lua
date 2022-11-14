--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LOG
--=============================================================================
-- Utility functions for logging
--_____________________________________________________________________________

local log = {}

---@type boolean
log.silent = false
---@type number
log.level = vim.log.levels.INFO

---@param m any: Text to log
---@param level number: A vim.log.levels value
local function notify(m, level)
  if log.silent == true or log.level > level then
    return
  end
  vim.notify(m, level)
end

---Notify the provided text with debug level.
---@param m any: Text to log
function log.debug(m)
  notify(m, vim.log.levels.DEBUG)
end

---Notify the provided text with info level.
---@param m any: Text to log
function log.info(m)
  notify(m, vim.log.levels.INFO)
end

---Notify the provided text with warn level.
---@param m any: Text to log
function log.warn(m)
  notify(m, vim.log.levels.WARN)
end

---Notify the provided text with error level.
---@param m any: Text to log
function log.error(m)
  notify(m, vim.log.levels.ERROR)
end

return log
