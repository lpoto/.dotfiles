--=============================================================================
-------------------------------------------------------------------------------
--                                                              NVIM-TREESITTER
--=============================================================================
-- https://github.com/nvim-treesitter/nvim-treesitter
--_____________________________________________________________________________

require("plugin").new {
  "nvim-treesitter/nvim-treesitter",
  as = "nvim-treesitter",
  required_executables = { { "tree-sitter", "Tree Sitter CLI" } },
  config = function()
    local treesitter = require "nvim-treesitter.configs"
    treesitter.setup {
      ensure_installed = "all",
      --sync_install = true,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = false,
      },
    }
  end,
}
