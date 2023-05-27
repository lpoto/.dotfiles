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

local format
function M.format_selection()
  return format(true)
end

function M.format()
  return format(false)
end

M.keys = {
  { "<leader>f", M.format, mode = "n" },
  { "<leader>f", M.format_selection, mode = "v" },
}

function M.config()
  Util.require("null-ls", function(null_ls)
    null_ls.setup()
  end)
end

---@param selection boolean: Format only current selection
function format(selection)
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
    Util.log("null-ls.format"):warn(e)
  end
end

---@param opts string|table
function M.register_formatter(opts)
  M.register_builtin_source("formatting", opts)
end

---@param opts string|table
function M.register_linter(opts)
  M.register_builtin_source("diagnostics", opts)
end

local expand_opts
---@param type string
---@param opts string|table
function M.register_builtin_source(type, opts)
  Util.require("null-ls", function(null_ls)
    opts = expand_opts(opts)

    local s = null_ls.builtins[type][opts.source]
    if not s then
      Util.log("null-ls"):warn("No such builtin source:", opts.source)
      return
    end
    if opts.config and next(opts.config) then
      s = s.with(opts.config)
    end
    null_ls.register {
      filetypes = { opts.filetype },
      sources = { s },
    }
  end)
end

expand_opts = function(opts)
  local o = {}
  if type(opts) == "string" then
    o.source = opts
    o.filetype = vim.bo.filetype
  else
    opts = opts or {}

    o.source = opts[1]
    if type(o.source) ~= "string" then
      o.source = opts.source
    end

    opts.source = nil
    opts[1] = nil
    opts.filetype = nil

    o.filetype = opts.filetype or vim.bo.filetype
    o.config = opts
  end
  return o
end

return M
