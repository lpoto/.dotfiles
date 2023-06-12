--=============================================================================
-------------------------------------------------------------------------------
--                                                                     NVIM-CMP
--[[===========================================================================
https://github.com/hrsh7th/nvim-cmp

A completion engine plugin. Completion sources are installed from
external repositories, cmp-nvim-lsp,...

This also includes the vsnip plugin intergrated with cmp,
and autopairs, that autocompletes the matching braces, quotes, etc.

To enable this for a lsp server, add the following to  the
lsp server's config:
 capabilities = require('plugins.cmp').capabilities()

-----------------------------------------------------------------------------]]
local M = {
  "hrsh7th/nvim-cmp",
  event = { "BufRead", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "L3MON4d3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
}

local set_confirm_keymap

function M.config()
  Util.require("cmp", function(cmp)
    cmp.setup {
      completion = {
        completeopt = "menu,menuone,noinsert,noselect",
      },
      snippet = {
        expand = function(args)
          Util.require("luasnip", function(luasnip)
            luasnip.lsp_expand(args.body)
          end)
        end,
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer" },
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
        ["<TAB>"] = cmp.mapping.select_next_item(),
        ["<S-TAB>"] = cmp.mapping.select_prev_item(),
        ["<C-x>"] = cmp.mapping.close(),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
      },
    }
    set_confirm_keymap()
  end)
end

function M.capabilities()
  return Util.require("cmp_nvim_lsp", function(cmp_nvim_lsp)
    return cmp_nvim_lsp.default_capabilities()
  end)
end

--- If copilot suggestion is visible and cmp has no selected entry,
--- <CR> will accept suggestion, otherwise if there is no
--- copilot suggestion and cmp is visible, <CR> will select
--- the first cmp entry, otherwise <CR> will just do
--- its default behavior.
function set_confirm_keymap()
  vim.keymap.set("i", "<CR>", function()
    local suggestion = Util.require "copilot.suggestion"
    local cmp = Util.require "cmp"
    if
      cmp
      and (
        cmp.visible() and cmp.get_selected_entry() ~= nil
        or cmp.visible() and (not suggestion or not suggestion.is_visible())
      )
    then
      vim.defer_fn(function()
        cmp.confirm { select = true }
      end, 5)
      return true
    end
    if suggestion and suggestion.is_visible() then
      vim.defer_fn(function()
        suggestion.accept()
      end, 5)
      return true
    end
    return "<CR>"
  end, { expr = true, remap = true })
end

return M
