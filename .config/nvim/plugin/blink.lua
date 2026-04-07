--=============================================================================
--                                                                    BLINK CMP
--[[===========================================================================
--
-- Setup for blink.cmp, an autocompletion plugin. The current
-- builtin autocompletion does not support multiple sources, so
-- blink.cmp is used until the builtin one matures enough.
--
-----------------------------------------------------------------------------]]

vim.pack.add {
  {
    src = "https://github.com/saghen/blink.cmp",
    version = "v1.10.2"
  }
}

--- NOTE: Lazy load blink.cmp when the user enters insert mode for
--- the first time, as we don't need it before that.
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  once = true,
  callback = function()
    require "blink-cmp".setup {
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
      }
    }
  end
})
