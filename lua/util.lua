--=============================================================================
-------------------------------------------------------------------------------
--                                                                         UTIL
--[[===========================================================================
Util functions
-----------------------------------------------------------------------------]]
local util = {}

--- Return a function that tries to search upward
--- for the provided patterns and returns the first
--- matching directory containing that pattern.
--- If no match is found, return the default value or
--- the current working directory if no default is provided.
--- @param patterns string[]
--- @param default string?
--- @param opts table?
--- @return function
function util.root_fn(patterns, default, opts)
  return function()
    opts = opts or {}
    if opts.path == nil then
      opts.path = vim.fn.expand "%:p:h"
    end
    local f =
      vim.fs.find(patterns, vim.tbl_extend("force", { upward = true }, opts))
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

--- catch errors from require and display them in a notification,
--- so multiple modules may be loaded even if one fails
---
--- Callback will be called only if all modules are loaded successfully.
---
--- @param module string|table
--- @param callback function?
function util.require(module, callback)
  if type(module) == "string" then
    module = { module }
  elseif type(module) ~= "table" then
    util.log():warn "module must be a string or table"
  end
  local res = {}
  for _, m in ipairs(module) do
    local ok, v = pcall(require, m)
    if not ok then
      util.log(250):warn("Error loading", m, "-", v)
      return
    end
    table.insert(res, v)
  end
  if type(callback) == "function" then
    local ok, v = pcall(callback, unpack(res))
    if not ok then
      util.log(250):error(v)
      return
    end
    return v
  end
  return unpack(res)
end

local loaded = {}
local _ftplugin

---@class FtpluginOpts
---@field language_server string|table?
---@field formatter string|table?
---@field linter string|table?
---
---@param opts FtpluginOpts
function util.ftplugin(opts)
  vim.defer_fn(function()
    _ftplugin(opts)
  end, 100)
end

function _ftplugin(opts)
  local filetype = vim.bo.filetype
  -- Load ftplugin only when opening a buffer
  -- with "" buftype for the first time.
  local buftype = vim.bo.buftype
  if buftype ~= "" or loaded[filetype] then
    return
  end
  loaded[filetype] = true

  opts = opts or {}
  if type(opts) ~= "table" then
    opts = {}
  end

  -- Allow setting the language server, formatter and linter
  -- with global variables, so the default config may be overriden
  -- in local configs
  opts.language_server = vim.g[filetype .. "_language_server"]
    or opts.language_server
  opts.formatter = vim.g[filetype .. "_formatter"] or opts.formatter
  opts.linter = vim.g[filetype .. "_linter"] or opts.linter

  -- Safe require lspconfig and null-ls and start language server
  -- and add formatters/linters only on successful require
  util.require("plugins.lspconfig", function(lspconfig)
    if type(lspconfig) == "table" then
      if
        type(opts.language_server) == "string"
        or type(opts.language_server) == "table"
      then
        lspconfig.start_language_server(opts.language_server)
      end
    end
  end)
  if not opts.formatter and not opts.linter then
    return
  end

  util.require("plugins.null-ls", function(null_ls)
    if type(null_ls) == "table" then
      if
        type(opts.formatter) == "string" or type(opts.formatter) == "table"
      then
        null_ls.register_formatter(opts.formatter)
      end
      if type(opts.linter) == "string" or type(opts.linter) == "table" then
        null_ls.register_linter(opts.linter)
      end
    end
  end)
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

---@class Log
---@field title string?
---@field delay number?
local Log = {}
Log.__index = Log
local __notify

function Log:info(...)
  __notify(vim.log.levels.INFO, self.title, self.delay, ...)
end

function Log:warn(...)
  __notify(vim.log.levels.WARN, self.title, self.delay, ...)
end

function Log:error(...)
  __notify(vim.log.levels.ERROR, self.title, self.delay, ...)
end

---@param delay number?: Delay in milliseconds, default: 0
---@param title string?: Title of the notification
---@return Log
function util.log(delay, title)
  local o = {}
  if type(title) == "string" then
    o.title = title
  end
  if type(delay) == "number" then
    o.delay = delay
  end
  return setmetatable(o, Log)
end

function __notify(level, title, delay, ...)
  local n = debug.getinfo(3)

  local msg = util.concat(...)
  delay = delay or 0

  if type(title) ~= "string" then
    if type(n) == "table" then
      local ok = false
      if type(n.short_src) == "string" then
        title = vim.fn.fnamemodify(n.short_src, ":t")
        ok = true
      end
      if type(n.name) == "string" then
        if ok then
          title = title .. ":" .. n.name
        else
          title = n.name
          ok = true
        end
      end
      if ok and type(n.currentline) == "number" then
        title = title .. ":" .. n.currentline
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

return util
