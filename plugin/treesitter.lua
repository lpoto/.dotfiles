--=============================================================================
-------------------------------------------------------------------------------
--                                                              NVIM-TREESITTER
--=============================================================================
-- https://github.com/nvim-treesitter/nvim-treesitter
--_____________________________________________________________________________

require("plugin").new {
  "nvim-treesitter/nvim-treesitter",
  as = "nvim-treesitter.configs",
  run = ":TSUpdate",
  config = function(treesitter)
    treesitter.setup {
      ensure_installed = "all",
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
      },
      indent = {
        enable = false,
      },
    }
  end,
}
