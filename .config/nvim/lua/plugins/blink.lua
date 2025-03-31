--=============================================================================
--                                          https://github.com/saghen/blink.cmp
--=============================================================================

return {
  "saghen/blink.cmp",
  tag = "v1.0.0",
  event = { "BufRead", "BufNewFile" },
  dependencies = {
    {
      "saghen/blink.compat",
      tag = "v2.5.0",
      lazy = true,
      opts = {},
    },
    {
      "MattiasMTS/cmp-dbee",
      lazy = true,
      ft = "sql",
      opts = {}
    },
  },
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      per_filetype = {
        sql = { "dbee", "buffer" },
      },
      providers = {
        dbee = { name = "cmp-dbee", module = "blink.compat.source" }
      }
    },
    cmdline = {
      enabled = false
    },
    completion = {
      keyword = { range = "full" },
      accept = { auto_brackets = { enabled = false } },
      list = { selection = { preselect = false, auto_insert = true } },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 300,
      },
      ghost_text = {
        enabled = false,
      },
    },
    snippets = {
      preset = "default",
    },
    signature = {
      enabled = true,
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    keymap = {
      preset = "none",
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<S-TAB>"] = { "select_prev", "fallback" },
      ["<TAB>"] = { "select_next", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
  },
  opts_extend = { "sources.default" },
}
