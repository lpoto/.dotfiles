--=============================================================================
-------------------------------------------------------------------------------
--                                                                         UTIL
--[[===========================================================================
Util functions
-----------------------------------------------------------------------------]]
local util = {}

--- catch errors from require and display them in a notification,
--- so multiple modules may be loaded even if one fails
--- @param module string
function util.require(module)
  local ok, v = pcall(require, module)
  if not ok and type(v) == "string" then
    vim.defer_fn(function()
      util.logger("Util - Require"):error("Failed to load", module, "-", v)
    end, 500)
    return nil
  end
  return v
end

--- Return a function that tries to search upward
--- for the provided patterns and returns the first
--- matching directory containing that pattern.
--- If no match is found, return the default value or
--- the current working directory if no default is provided.
--- @param patterns string[]
--- @param default string?
--- @param opts table?
function util.root_fn(patterns, default, opts)
  return function()
    local f = vim.fs.find(
      patterns,
      vim.tbl_extend("force", {
        upward = true,
      }, opts or {})
    )
    if not f or not next(f) then
      return default or vim.fn.getcwd()
    end
    return vim.fs.dirname(f[1])
  end
end

---Return the current neovim version as a string.
---@return string
function util.nvim_version()
  local version = vim.version()

  local s = version.major
  s = s .. "." .. version.minor
  s = s .. "." .. version.patch
  if version.prerelease then
    s = s .. " (prerelease)"
  end
  return s
end

---Return the path separator based on the
---current operating system.
function util.path_separator()
  local separator = "/"
  if vim.fn.has "win32" == 1 or vim.fn.has "win32unix" == 1 then
    separator = "\\"
  end
  return separator
end

---Joins arbitrary number of paths together.
---@param ... string The paths to join.
---@return string
function util.path(...)
  local args = { ... }
  if #args == 0 then
    return ""
  end
  local separator = util.path_separator()
  local all_parts = {}
  if type(args[1]) == "string" and args[1]:sub(1, 1) == separator then
    all_parts[1] = ""
  end
  for _, arg in ipairs(args) do
    local arg_parts = vim.fn.split(arg, separator)
    vim.list_extend(all_parts, arg_parts)
  end
  return table.concat(all_parts, separator)
end

---Escape the path separator in a path with the provided replacement,
---or "_" if no replacement is provided.
function util.escape_path(path, separator_replacement)
  local separator = util.path_separator()
  local replacement = separator_replacement or "_"
  local s = path:gsub(separator, replacement)
  return s
end

---Unescape the path separator in a path with the provided replacement,
---or "_" if no replacement is provided.
function util.unescape_path(path, separator_replacement)
  local separator = util.path_separator()
  local replacement = separator_replacement or "_"
  local s = path:gsub(replacement, separator)
  return s
end

---Change the provided directory name form, example "undo" to "undo/"
---or "undo\\" depending on the operating system.
function util.dir(name)
  local separator = util.path_separator()
  local s = vim.fn.fnamemodify(name .. separator .. "x.lua", ":h")
  return s .. separator
end

---@class Logger
---@field name string
util.Logger = {}
util.Logger.__index = util.Logger

---Create a new logger.
---@param ... any: The name of the logger.
---@return Logger
function util.logger(...)
  local logger = setmetatable({
    name = util.concat(...),
  }, util.Logger)
  return logger
end

function util.Logger:info(...)
  self:notify(vim.log.levels.INFO, ...)
end

function util.Logger:warn(...)
  self:notify(vim.log.levels.WARN, ...)
end

function util.Logger:error(...)
  self:notify(vim.log.levels.WARN, ...)
end

function util.Logger:notify(lvl, ...)
  local msg = util.concat(...)
  vim.schedule(function()
    if msg:len() > 0 then
      vim.notify(msg, lvl, {
        title = self.name,
      })
    end
  end)
end

function util.concat(...)
  local s = ""
  for _, v in ipairs { select(1, ...) } do
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

return util