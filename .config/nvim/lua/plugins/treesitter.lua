--=============================================================================
--                           https://github.com/nvim-treesitter/nvim-treesitter
--=============================================================================

local M = {
  "nvim-treesitter/nvim-treesitter",
  tag = "v0.9.3",
  lazy = false,
}

function M.init() vim.opt.foldlevelstart = 99 end

function M.config()
  require "nvim-treesitter.configs".setup {
    auto_install = true,
    sync_install = true,
    ignore_install = {},
    ensure_installed = { "c", "lua", "vim", "vimdoc" },
    modules = {},
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
        node_decremental = "<BS>",
      },
    },
  }
end

--NOTE: install mandatory parsers on build
function M.build()
  local ensure_installed = {
    "c",
    "lua",
    "vim",
    "vimdoc",
    "markdown",
    "regex",
    "markdown_inline",
    "bash",
    "gitcommit",
    "git_config",
    "git_rebase",
    "gitattributes",
  }
  vim.cmd("TSUpdateSync " .. table.concat(ensure_installed, " "))
end

return M
