--=============================================================================
-------------------------------------------------------------------------------
--                                                              NVIM-TREESITTER
--=============================================================================
-- https://github.com/nvim-treesitter/nvim-treesitter
--_____________________________________________________________________________

--[[
Treesitter interface for Neovim. Provides inproved
highlights, ...
--]]

return {
  "nvim-treesitter/nvim-treesitter",
  event = "VeryLazy",
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
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<A-v>",
          node_incremental = "<A-v>",
          scope_incremental = "<A-v>",
          node_decremental = "<A-b>",
        },
      },
    }
  end,
}
