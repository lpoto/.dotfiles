--==============================================================================
--                                                                        VIMTEX
--[[============================================================================
https://github.com/lervag/vimtex

vimtex is a comprehensive Vim plugin for editing LaTeX documents.
-----------------------------------------------------------------------------]]

local M = {
  "lervag/vimtex",
  ft = "tex",
}

function M.config()
  vim.g.vimtex_quickfix_enabled = 1
  vim.g.vimtex_syntax_enabled = 1
  vim.g.vimtex_quickfix_mode = 0
  pcall(vim.api.nvim_exec, "call vimtex#init()", true)
end

return M
