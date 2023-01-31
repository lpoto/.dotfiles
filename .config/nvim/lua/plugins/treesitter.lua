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
  build = "TSUpdate",
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
      -- incremental_selection = {
      --   enable = true,
      --   keymaps = {
      --     init_selection = "<leader>v",
      --     node_incremental = "<leader>v",
      --     scope_incremental = "<leader>v",
      --     node_decremental = "<A-v>",
      --   },
      -- },
    }
  end,
}
