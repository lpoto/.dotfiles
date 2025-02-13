--=============================================================================
--                                          https://github.com/saghen/blink.cmp
--=============================================================================
return {
  "saghen/blink.cmp",
  tag = "v0.11.0",
  event = { "BufRead", "BufNewFile" },
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      cmdline = {},
    },
    completion = {
      keyword = { range = "full" },
      accept = { auto_brackets = { enabled = false } },
      list = { selection = { preselect = false, auto_insert = true } },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = {
          border = "rounded",
        },
      },
      ghost_text = {
        enabled = true,
      },
      menu = {
        border = "rounded",
      },
    },
    snippets = {
      preset = "default",
    },
    signature = {
      enabled = true,
      window = {
        border = "rounded",
      },
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
