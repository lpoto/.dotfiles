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
    sync_install = true,
    auto_install = true,
    --  ensure_installed = "all",  -- enabling this will install all parses when
    -- first opening neovim, it's better to keep it default, so each
    -- parser is installed when it's filetype is opened for the first time
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
