--=============================================================================
-------------------------------------------------------------------------------
--                                                                         PATH
--=============================================================================
-- Path utils for joining, splitting ,... paths
--_____________________________________________________________________________

local M = {}

---The file system path separator for the current platform.
M.separator = "/"
M.is_windows = vim.fn.has "win32" == 1 or vim.fn.has "win32unix" == 1
if M.is_windows == true then
  M.separator = "\\"
end

---Split the provided path into a table of strings using a separator.
---@param path string The string to split.
---@param sep string The separator to use.
---@return table table A table of strings.
M.split = function(path, sep)
  local fields = {}

  local pattern = string.format("([^%s]+)", sep)
  local _ = string.gsub(path, pattern, function(c)
    fields[#fields + 1] = c
  end)

  return fields
end

---Joins arbitrary number of paths together.
---@param ... string The paths to join.
---@return string
M.join = function(...)
  local args = { ... }
  if #args == 0 then
    return ""
  end

  local all_parts = {}
  if type(args[1]) == "string" and args[1]:sub(1, 1) == M.separator then
    all_parts[1] = ""
  end

  for _, arg in ipairs(args) do
    local arg_parts = M.split(arg, M.separator)
    vim.list_extend(all_parts, arg_parts)
  end
  if args[#args] == "" then
    table.insert(all_parts, "")
  end
  return table.concat(all_parts, M.separator)
end

return M
