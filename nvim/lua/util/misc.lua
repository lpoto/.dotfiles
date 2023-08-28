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
---@param server string|table
---@diagnostic disable-next-line: unused-local
function Misc.attach_language_server(server)
  util.log():warn("'attach_language_server' was not overridden")
end

---Attach the provided formatter. This
---should be overridden by plugins that provide formatting.
---@param cfg string|function
---@param filetype string
---@diagnostic disable-next-line: unused-local
function Misc.attach_formatter(cfg, filetype)
  util.log():warn("'attach_formatter' was not overridden")
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
    if opts.path == nil then opts.path = vim.fn.expand("%:p:h") end
    local f = nil
    if type(patterns) == "table" and next(patterns) then
      f = vim.fs.find(
        patterns,
        vim.tbl_extend("force", { upward = true }, opts)
      )
    end
    if type(f) ~= "table" or not next(f) then
      if type(default) == "string" then return default end
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
  if version.prerelease then s = s .. " (prerelease)" end
  return s
end

---Toggle quickfix window
---@param navigate_to_quickfix boolean?: Navigate to quickfix window after opening it
---@param open_only boolean?: Do not close quickfix if already open
function Misc.toggle_quickfix(navigate_to_quickfix, open_only)
  if
    #vim.tbl_filter(
      function(winid)
        return vim.api.nvim_buf_get_option(
          vim.api.nvim_win_get_buf(winid),
          "buftype"
        ) == "quickfix"
      end,
      vim.api.nvim_list_wins()
    ) > 0
  then
    if open_only ~= true then vim.api.nvim_exec2("cclose", {}) end
  else
    local winid = vim.api.nvim_get_current_win()
    vim.api.nvim_exec2("noautocmd keepjumps copen", {})
    if
      #vim.tbl_filter(
        function(l) return #l > 0 end,
        vim.api.nvim_buf_get_lines(0, 0, -1, false)
      ) == 0
    then
      vim.api.nvim_exec2("cclose", {})
      navigate_to_quickfix = true
      Util.log("Quickfix")
        :warn("There is nothing to display in the quickfix window")
    end
    if navigate_to_quickfix ~= true then vim.fn.win_gotoid(winid) end
  end
end

return Misc
