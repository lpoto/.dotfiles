--=============================================================================
--
--                                          https://github.com/ibhagwan/fzf-lua
--[[===========================================================================
Fuzzy finder over lists.

Keymaps:
 - "<leader><Space>"   - find files
 - "<leader>o"         - old files
 - "<leader>l"         - live grep
 - "<leader>L"         - live grep word under cursor

 - "<leader>c"         - continue previous picker

 - "<leader>m"         - marks
 - "<leader>h"         - Search help tags

 - "<leader>e"         - show document diagnostics, or on current line
 - "<leader>E"         - show workspace diagnostics
 - "gd"                - LSP definitions
 - "gi"                - LSP implementations
 - "gr"                - LSP references

 Use <C-q> in a telescope prompt to send the results to quickfix.
-----------------------------------------------------------------------------]]

local function builtin(p)
  return function() require("fzf-lua")[p]() end
end
return {
  "ibhagwan/fzf-lua",
  commit = "54d505c",
  event = "VeryLazy",
  keys = {
    { "<leader><space>", builtin "files" },
    { "<leader>o", builtin "oldfiles" },
    { "<leader>l", builtin "live_grep" },
    { "<leader>L", builtin "grep_cword" },
    { "<leader>c", builtin "resume" },
    { "<leader>m", builtin "marks" },
    { "<leader>h", builtin "helptags" },
    { "gd", builtin "lsp_definitions" },
    { "gi", builtin "lsp_implementations" },
    { "gr", builtin "lsp_references" },
    --{ "<leader>a", builtin "lsp_code_actions" },
    { "<leader>q", builtin "quickfix" },
    { "<leader>E", builtin "diagnostics_workspace" },
    {
      "<leader>e",
      function()
        if not vim.diagnostic.open_float() then
          builtin "diagnostics_document"()
        end
      end,
    },
  },
  config = function()
    local fzf = require "fzf-lua"
    fzf.setup {
      keymap = {
        fzf = {
          ["ctrl-q"] = "select-all+accept",
        },
        builtin = {
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
        },
      },
    }
    fzf.register_ui_select {
      winopts = {
        width = 0.4,
        height = 0.4,
      },
    }
  end,
  init = function()
    vim.cmd "let $FZF_DEFAULT_OPTS = '--bind tab:down,shift-tab:up --cycle'"
  end,
}
