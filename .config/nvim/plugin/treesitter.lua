--=============================================================================
--                                                                   TREESITTER
--[[===========================================================================

Configures nvim-treesitter manager, that provides configurations and queries
for treesitter parsers.

NOTE: requires tree-sitter CLI

Relevant commands:
- :TSManager    (Open the interface for managing parsers)

-----------------------------------------------------------------------------]]

vim.pack.add {
  {
    src = "https://github.com/romus204/tree-sitter-manager.nvim",
    version = "33a94d0"
  }
}

vim.opt.foldlevelstart = 99

require "tree-sitter-manager".setup {
  highlight = true,
  border = "rounded",
  auto_install = true,
  ensure_installed = {
    "c",
    "bash",
    "zsh",
    "lua",
    "vim",
    "vimdoc",
    "markdown",
    "markdown_inline",
    "make",
    "regex",
    "gitcommit",
    "git_rebase",
    "gitignore",
    "git_config",
    "gitattributes",
    "editorconfig",
    "dockerfile",
    "sql",
    "json",
    "yaml",
    "html",
    "xml",
    "toml",
    "css",
    "java",
    "javascript",
    "typescript",
    "python",
  }
}
