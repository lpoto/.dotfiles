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
  event = {"BufRead", "BufNewFile"},
}

function M.config()
  local treesitter = require "nvim-treesitter.configs"

  treesitter.setup {
    -- NOTE: the following 5 parsers should always be installed
    -- when opening nvim for the first time.
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
    -- Parsers will be installed when entering the matching filetype.
    auto_install = true,
    sync_install = false,
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
