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
  cmd = { "TSUpdate", "TSInstall", "TSUpdateSync", "TSInstallSync" },
}

function M.config()
  Util.require("nvim-treesitter.configs", function(treesitter)
    treesitter.setup({
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

Util.setup["treesitter"] = function()
  local ensure_installed = {
    "c",
    "lua",
    "vim",
    "vimdoc",
    "markdown",
    "markdown_inline",
    "bash",
    "gitcommit",
    "git_config",
    "git_rebase",
    "gitattributes",
  }
  vim.api.nvim_exec2(
    "TSUpdateSync " .. table.concat(ensure_installed, " "),
    {}
  )
end

return M
