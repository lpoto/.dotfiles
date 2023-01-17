return {
  "anuvyklack/pretty-fold.nvim",
  keys = { "za" },
  config = function()
    vim.opt.foldmethod = "expr" -- enable folding (default 'foldmarker')
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt.foldlevel = 9999 -- open a file fully expanded, set to
    require("pretty-fold").setup()
  end,
}
