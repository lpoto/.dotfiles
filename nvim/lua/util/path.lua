local util = require("util")

---@class PathUtil
local Path = {
  separator = vim.fn.has("win32") == 1
    or vim.fn.has("win32unix") == 1 and "\\"
    or "/",
}

---Joins arbitrary number of paths together.
---@param ... any The paths to join.
---@return string
function Path:new(...)
  local args = { ... }
  local ok, v = pcall(function()
    if #args == 0 then
      return ""
    end
    local all_parts = {}
    if type(args[1]) == "string" and args[1]:sub(1, 1) == self.separator then
      all_parts[1] = ""
    end
    for _, arg in ipairs(args) do
      if type(arg) == "string" then
        args = vim.fn.split(arg, self.separator)
        for _, part in ipairs(args) do
          if part:len() > 0 then
            local arg_parts = vim.fn.split(part, self.separator)
            vim.list_extend(all_parts, arg_parts)
          end
        end
      end
    end
    return table.concat(all_parts, self.separator)
  end)
  if not ok then
    util.log():warn("Failed to join paths:", v)
    return ""
  end
  return v
end

---Escape the path separator in a path with the provided replacement,
---or "_" if no replacement is provided.
---@param s string The path to escape.
---@param separator_replacement string? The replacement for the separator.
function Path:escape(s, separator_replacement)
  s = s:gsub("^" .. os.getenv("HOME"), "HOME")
  local replacement = separator_replacement or "_"
  return s:gsub(self.separator, replacement)
end

---Unescape the path separator in a path with the provided replacement,
---or "_" if no replacement is provided.
function Path:unescape(s, separator_replacement)
  s = s:gsub("^HOME", os.getenv("HOME"))
  local replacement = separator_replacement or "_"
  return s:gsub(replacement, self.separator)
end

---Change the provided directory name form, example "undo" to "undo/"
---or "undo\\" depending on the operating system.
function Path:dir(name)
  local s = vim.fn.fnamemodify(name .. self.separator .. "x.lua", ":h")
  return s .. self.separator
end

local stdpath = vim.fn.stdpath
---@param what string
---@return string|table
function Path.stdpath(what)
  local app_name = os.getenv("NVIM_APPNAME")
  local config = vim.fs.dirname(stdpath("config"))
  local storage = Path:new(config, ".storage")

  local n = {
    config = Path:new(config, app_name),
    cache = Path:new(storage, "cache", app_name),
    data = Path:new(storage, "share", app_name),
    log = Path:new(storage, "log", app_name),
    run = Path:new(storage, "state", app_name),
    state = Path:new(storage, "state", app_name),
    config_dirs = {},
    data_dirs = {},
  }
  return Path:new(n[what] or stdpath(what))
end

return Path
