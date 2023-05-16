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

function M.config()
  local cmp = require "cmp"

  cmp.setup {
    completion = {
      completeopt = "menu,menuone,noinsert,noselect",
    },
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    sources = {
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "path" },
      { name = "buffer" },
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    preselect = cmp.PreselectMode.None,
    mapping = cmp.mapping.preset.insert {
      ["<TAB>"] = cmp.mapping.select_next_item(),
      ["<S-TAB>"] = cmp.mapping.select_prev_item(),
      ["<CR>"] = cmp.mapping.confirm { select = true },
      ["<C-x>"] = cmp.mapping.close(),
    },
  }
end

function M.capabilities()
  return require("cmp_nvim_lsp").default_capabilities()
end

return M
