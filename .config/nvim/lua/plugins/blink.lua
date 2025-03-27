--=============================================================================
--                                          https://github.com/saghen/blink.cmp
--=============================================================================

return {
  "saghen/blink.cmp",
  tag = "v1.0.0",
  event = { "BufRead", "BufNewFile" },
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
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
