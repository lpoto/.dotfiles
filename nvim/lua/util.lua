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
--- @param patterns string[]?
--- @param default string?
--- @param opts table?
--- @return function
function util.root_fn(patterns, default, opts)
  return function()
    opts = opts or {}
    if opts.path == nil then
      opts.path = vim.fn.expand "%:p:h"
    end
    local f = nil
    if type(patterns) == "table" and next(patterns) then
      f = vim.fs.find(
        patterns,
        vim.tbl_extend("force", { upward = true }, opts)
      )
    end
    if type(f) ~= "table" or not next(f) then
      if type(default) == "string" then
        return default
      end
      return vim.fn.getcwd()
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
---@param ... any The paths to join.
---@return string
function util.path(...)
  local args = { ... }
  local ok, v = pcall(function()
    if #args == 0 then
      return ""
    end
    local separator = util.path_separator()
    local all_parts = {}
    if type(args[1]) == "string" and args[1]:sub(1, 1) == separator then
      all_parts[1] = ""
    end
    for _, arg in ipairs(args) do
      if type(arg) == "string" then
        args = vim.fn.split(arg, separator)
        for _, part in ipairs(args) do
          if part:len() > 0 then
            local arg_parts = vim.fn.split(part, separator)
            vim.list_extend(all_parts, arg_parts)
          end
        end
      end
    end
    return table.concat(all_parts, separator)
  end)
  if not ok then
    util.log():warn("Failed to join paths:", v)
    return ""
  end
  return v
end

---Escape the path separator in a path with the provided replacement,
---or "_" if no replacement is provided.
---@param path string The path to escape.
---@param separator_replacement string? The replacement for the separator.
function util.escape_path(path, separator_replacement)
  path = path:gsub("^" .. os.getenv "HOME", "HOME")
  local separator = util.path_separator()
  local replacement = separator_replacement or "_"
  local s = path:gsub(separator, replacement)
  return s
end

---Unescape the path separator in a path with the provided replacement,
---or "_" if no replacement is provided.
function util.unescape_path(path, separator_replacement)
  path = path:gsub("^HOME", os.getenv "HOME")
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
local ftplugins_waiting = {}
local ftplugin_id = 0
local _ftplugin

---@class FtpluginOpts
---@field language_server string|table?
---@field formatter string|table?
---@field linter string|table?
---@field filetype string?
---@field init function?
---
---@param opts FtpluginOpts
function util.ftplugin(opts)
  if type(opts) ~= "table" then
    opts = {}
  end
  local filetype = opts.filetype
  local buftype = ""
  if type(filetype) ~= "string" then
    filetype = vim.bo.filetype
    buftype = vim.bo.buftype
  end
  if buftype ~= "" or loaded[filetype] then
    return
  end
  opts.filetype = filetype
  -- Wait before loading ftplugin a bit.
  -- While waiting a ftplugin with the same filetype
  -- will override the one waiting.
  -- This is useful for chaning ftplugin configs
  -- in local configs.
  local id = ftplugin_id
  ftplugins_waiting[filetype] = id
  ftplugin_id = ftplugin_id + 1
  vim.defer_fn(function()
    if ftplugins_waiting[filetype] ~= id then
      return
    end
    loaded[filetype] = true
    ftplugins_waiting[filetype] = nil
    _ftplugin(opts)
  end, 250)
end

function _ftplugin(opts)
  local filetype = opts.filetype or vim.bo.filetype
  if type(opts.init) == "function" then
    local ok, err = pcall(opts.init)
    if not ok then
      util.log(200):error(err)
    end
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

local stdpath = vim.fn.stdpath
---@param what string
---@return string|table
function util.stdpath(what)
  local app_name = os.getenv "NVIM_APPNAME"
  local config = vim.fs.dirname(stdpath "config")
  local storage = util.path(config, ".storage")

  local n = {
    config = util.path(config, app_name),
    cache = util.path(storage, "cache", app_name),
    data = util.path(storage, "share", app_name),
    log = util.path(storage, "log", app_name),
    run = util.path(storage, "state", app_name),
    state = util.path(storage, "state", app_name),
    config_dirs = {},
    data_dirs = {},
  }
  return util.path(n[what] or stdpath(what))
end

---@class Log
---@field title string?
---@field delay number?
local Log = {}
Log.__index = Log
local __notify

function Log:debug(...)
  __notify("debug", self.title, self.delay, ...)
end

function Log:info(...)
  __notify("info", self.title, self.delay, ...)
end

function Log:warn(...)
  __notify("warn", self.title, self.delay, ...)
end

function Log:error(...)
  __notify("error", self.title, self.delay, ...)
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

---@param callback function(remote: string, branch: string)
---@param on_error nil|function(exit_code: number)
function util.fetch_git_data(callback, on_error)
  on_error = on_error
    or function(_)
      util.log():warn "Could not fetch git data"
    end
  local remote = ""
  vim.fn.jobstart("git remote show", {
    detach = false,
    on_stdout = function(_, data)
      for _, d in ipairs(data) do
        if d:len() > 0 then
          remote = d
        end
      end
    end,
    on_exit = function(_, remote_exit_code)
      if remote_exit_code ~= 0 then
        if type(on_error) == "function" then
          return on_error()
        end
        return
      end
      local branch = ""
      vim.fn.jobstart("git branch --show-current", {
        detach = false,
        on_stdout = function(_, data)
          for _, d in ipairs(data) do
            if d:len() > 0 then
              branch = d
            end
          end
        end,
        on_exit = function(_, code)
          if code ~= 0 then
            if type(on_error) == "function" then
              return on_error()
            end
            return
          end
          return callback(remote, branch)
        end,
      })
    end,
  })
end

---@param cmd string|table
function util.run_shell_command_in_tab(cmd)
  local new_tab = true
  if vim.b.terminal_job_id then
    local r = vim.fn.jobwait({ vim.b.terminal_job_id }, 0)
    local _, n = next(r)
    if n == -3 then
      new_tab = false
    end
  end
  vim.schedule(function()
    local ok, e = pcall(function()
      if new_tab then
        vim.api.nvim_exec("keepjumps tabnew", false)
      else
        vim.api.nvim_buf_set_option(0, "modified", false)
      end
      vim.bo.bufhidden = "wipe"
      vim.bo.buflisted = false
      vim.fn.termopen(cmd, {
        detach = true,
        env = {
          VISUAL = "nvim",
          EDITOR = "nvim",
        },
      })
    end)
    if not ok and type(e) == "string" then
      util.log():warn(e)
    end
  end)
end

---@param cmd string|table
---@param suffix string
function util.run_shell_command_in_tab_with_prompt(cmd, suffix)
  suffix = vim.fn.input {
    prompt = "$ " .. (cmd or ""),
    default = suffix,
    cancelreturn = false,
  }
  if type(suffix) ~= "string" then
    return
  end
  util.run_shell_command_in_tab(cmd .. " " .. suffix)
end

return util
