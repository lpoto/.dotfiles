--=============================================================================
-------------------------------------------------------------------------------
--                                                                 NULL-LS.NVIM
--[[===========================================================================
https://github.com/jose-elias-alvarez/null-ls.nvim

Injects lsp diagnostics, code actions, formatting,...

Keymaps:
  - <leader>f  - Format current file and save (or selection if in visual mode)

Commands:
  - :NullLsInfo - Show information about the current null-ls session
  - :NullLsLog  - Open the log file
-----------------------------------------------------------------------------]]
local M = {
  "jose-elias-alvarez/null-ls.nvim",
  cmd = { "NullLsInfo", "NullLsLog" },
}

local __format
local function format_selection()
  return __format(true)
end
local function format()
  return __format(false)
end

M.keys = {
  { "<leader>f", format, mode = "n" },
  { "<leader>f", format_selection, mode = "v" },
}

function M.config()
  Util.require("null-ls", function(null_ls)
    null_ls.setup()
  end)
end

---@param selection boolean: Format only current selection
function __format(selection)
  local ok, e = pcall(function()
    local opts = {
      timeout_ms = 5000,
      async = true,
    }
    if selection then
      opts.range = {
        ["start"] = vim.api.nvim_buf_get_mark(0, "<"),
        ["end"] = vim.api.nvim_buf_get_mark(0, ">"),
      }
    end
    vim.lsp.buf.format(opts)
  end)
  if not ok and type(e) == "string" then
    Util.log():warn(e)
  end
end

local register_builtin_source

---Override the default attach_formatter function.
---@diagnostic disable-next-line: duplicate-set-field
Util.misc().attach_formatter = function(source, opts, filetypes)
  register_builtin_source("formatting", source, opts, filetypes)
end

---Override the default attach_linter function.
---@diagnostic disable-next-line: duplicate-set-field
Util.misc().attach_linter = function(source, opts, filetypes)
  register_builtin_source("diagnostics", source, opts, filetypes)
end

---@param t string
---@param source string
---@param opts table?
---@param filetypes string|table?
function register_builtin_source(t, source, opts, filetypes)
  Util.require("null-ls", function(null_ls)
    if type(opts) ~= "table" then
      opts = {}
    end
    filetypes = filetypes or vim.bo.filetype
    if type(filetypes) == "string" then
      filetypes = { filetypes }
    end

    local s = null_ls.builtins[t][source]
    if not s then
      Util.log():warn("No such builtin source:", source)
      return
    end

    Util.misc().ensure_source_installed("null-ls-source", source)

    vim.defer_fn(function()
      if opts and next(opts) then
        s = s.with(opts)
      end
      null_ls.register({
        filetypes = filetypes,
        sources = { s },
      })
      Util.log():debug("Registered source:", source, "(" .. t .. ")")
    end, 100)
  end)
end

return M
