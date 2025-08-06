--=============================================================================
--                                          https://github.com/saghen/blink.cmp
--=============================================================================
return {
  "saghen/blink.cmp",
  tag = "v1.6.0",
  event = { "BufRead", "BufNewFile" },
  dependencies = {
    {
      "saghen/blink.compat",
      tag = "v2.5.0",
      opts = {},
    },
  },
  opts_extend = { "sources.default" },
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        lsp = {
          min_keyword_length = 1,
          max_items = 7,
          score_offset = 100,
        },
        path = {
          min_keyword_length = 1,
          max_items = 10,
          score_offset = 100,
        },
        snippets = {
          min_keyword_length = 1,
          max_items = 10,
          score_offset = 80,
        },
        buffer = {
          min_keyword_length = 1,
          max_items = 10,
          score_offset = 70,
        },
      },
    },
    cmdline = {
      enabled = false
    },
    completion = {
      keyword = { range = "prefix" },
      accept = { auto_brackets = { enabled = true } },
      list = { selection = { preselect = false, auto_insert = true } },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 300,
      },
      ghost_text = {
        enabled = false,
      },
      trigger = {
        show_on_trigger_character = true,
        show_on_blocked_trigger_characters = { "\n", "\t" }
      }
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
      ["<C-x>"] = { "cancel", "fallback" },
      ["<S-TAB>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<C-p>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<TAB>"] = { "select_next", "snippet_forward", "fallback" },
      ["<C-n>"] = { "select_next", "snippet_forward", "fallback" },
      ["<C-y>"] = { "accept", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
  }
}
