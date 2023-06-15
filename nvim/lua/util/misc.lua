local util = require("util")

---@class MiscUtil
local Misc = {}

---Returns an autocompletion capabilities table. This
---should be overridden by plugins that provide autocompletion.
---@return table?
function Misc.get_autocompletion_capabilities()
  util.log():warn("'get_autocompletion_capabilities' was not overridden")
end

---Attach the provided language server. This
---should be overridden by plugins that provide lsp configurations.
---@param server string
---@param opts table?
---@diagnostic disable-next-line: unused-local
function Misc.attach_language_server(server, opts)
  util.log():warn("'attach_language_server' was not overridden")
end

---Attach the provided formatter. This
---should be overridden by plugins that provide formatting.
---@param formatter string
---@param opts table?
---@param filetypes string|table?
---@diagnostic disable-next-line: unused-local
function Misc.attach_formatter(formatter, opts, filetypes)
  util.log():warn("'attach_formatter' was not overridden")
end

---Attach the provided linter. This
---should be overridden by plugins that provide linting.
---@param linter string
---@param opts table?
---@param filetypes string|table?
---@diagnostic disable-next-line: unused-local
function Misc.attach_linter(linter, opts, filetypes)
  util.log():warn("'attach_linter' was not overridden")
end

---Check whether the buffer is marked. This should be
---overridden by plugins that provide buffer marking.
---@param buffer number
---@diagnostic disable-next-line: unused-local
function Misc.buffer_is_marked(buffer)
  return false
end

--- Return a function that tries to search upward
--- for the provided patterns and returns the first
--- matching directory containing that pattern.
--- If no match is found, return the default value or
--- the current working directory if no default is provided.
--- @param patterns string[]?
--- @param default string?
--- @param opts table?
--- @return function
function Misc.root_fn(patterns, default, opts)
  return function()
    opts = opts or {}
    if opts.path == nil then
      opts.path = vim.fn.expand("%:p:h")
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
function Misc.nvim_version()
  local version = vim.version()

  local s = version.major
  s = s .. "." .. version.minor
  s = s .. "." .. version.patch
  if version.prerelease then
    s = s .. " (prerelease)"
  end
  return s
end

return Misc
