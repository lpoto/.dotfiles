--=============================================================================
-------------------------------------------------------------------------------
--                                                              NVIM-TREESITTER
--[[===========================================================================
https://github.com/nvim-treesitter/nvim-treesitter

Treesitter interface for Neovim. Provides inproved
highlights, ...
-----------------------------------------------------------------------------]]
local M = {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufRead", "BufNewFile" },
}

function M.config()
  Util.require("nvim-treesitter.configs", function(treesitter)
    treesitter.setup({
      -- NOTE: the following parsers should always be installed
      -- when opening nvim for the first time.
      ensure_installed = {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "regex",
        "bash",
        "markdown",
        "markdown_inline",
      },
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
    })
  end)
end

return M
