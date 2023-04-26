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
local M = {
  "nvim-treesitter/nvim-treesitter",
  event = "VeryLazy",
}

function M.config()
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
        init_selection = "<CR>",
        node_incremental = "<CR>",
        --scope_incremental = "<CR>",
        node_decremental = "<BS>",
      },
    },
  }
end

return M
