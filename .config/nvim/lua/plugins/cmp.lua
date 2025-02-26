--=============================================================================
--                                          https://github.com/hrsh7th/nvim-cmp
--[[===========================================================================

A completion engine plugin. Completion sources are installed from
external repositories, cmp-nvim-lsp,...

-----------------------------------------------------------------------------]]

local M = {
  "hrsh7th/nvim-cmp",
  tag = "v0.0.2",
  event = { "BufRead", "BufNewFile" },
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp", commit = "99290b3" },
    { "hrsh7th/cmp-path", commit = "91ff86c" },
    { "hrsh7th/cmp-buffer", commit = "3022dbc" },
    { "hrsh7th/cmp-nvim-lsp-signature-help", commit = "031e6ba" },
    { "onsails/lspkind.nvim", commit = "d79a1c3" },
  },
}

function M.config()
  local cmp = require "cmp"
  ---@diagnostic disable-next-line: missing-fields
  cmp.setup {
    ---@diagnostic disable-next-line: missing-fields
    completion = {
      completeopt = "menu,menuone,noinsert,noselect",
    },
    snippet = {
      expand = function(args) vim.snippet.expand(args.body) end,
    },
    sources = {
      { name = "nvim_lsp", priority = 10, max_item_count = 20 },
      { name = "path", priority = 10, max_item_count = 5 },
      { name = "buffer", priority = 0, max_item_count = 5 },
      { name = "nvim_lsp_signature_help" },
    },
    window = {
      completion = cmp.config.window.bordered {
        winhighlight = "NormalFloat:WinSeparator,FloatBorder:WinSeparator",
      },
      documentation = cmp.config.window.bordered {
        winhighlight = "NormalFloat:WinSeparator,FloatBorder:WinSeparator",
      },
    },
    preselect = cmp.PreselectMode.None,
    mapping = cmp.mapping.preset.insert {
      ["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },
      ["<TAB>"] = cmp.mapping.select_next_item(),
      ["<S-TAB>"] = cmp.mapping.select_prev_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(4),
      ["<C-u>"] = cmp.mapping.scroll_docs(-4),
      ["<C-x>"] = cmp.mapping.close(),
    },
    formatting = {
      expandable_indicator = true,
      fields = { "kind", "abbr", "menu" },
      format = require("lspkind").cmp_format {
        mode = "symbol_test",
        maxwidth = {
          menu = 50,
          abbr = 50,
        },
        ellipsis_char = "...",
        show_labelDetails = true,
      },
    },
  }
end

return M
