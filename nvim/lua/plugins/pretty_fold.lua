--=============================================================================
-------------------------------------------------------------------------------
--                                                                  PRETTY-FOLD
--[[===========================================================================
https://github.com/anuvyklack/pretty-fold.nvim


Toggle fold on current context

mappings:
    za or <C-f> - toggle fold

-----------------------------------------------------------------------------]]
local M = {
  "anuvyklack/pretty-fold.nvim",
  keys = { "za" },
}

function M.config()
  vim.opt.foldmethod = "expr" -- enable folding (default 'foldmarker')
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldlevel = 9999 -- open a file fully expanded, set to
  require("pretty-fold").setup()
end

function M.init()
  vim.keymap.set("n", "<C-f>", function()
    vim.fn.feedkeys "za"
  end)
end

return M
