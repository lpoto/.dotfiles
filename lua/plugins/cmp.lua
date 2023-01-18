--=============================================================================
-------------------------------------------------------------------------------
--                                                                     NVIM-CMP
--=============================================================================
-- https://github.com/hrsh7th/nvim-cmp
--_____________________________________________________________________________

--[[
A completion engine plugin. Completion sources are installed from
external repositories, cmp-buffer, cmp-nvim-lsp,...

This also includes the vsnip plugin intergrated with cmp,
and autopairs, that autocompletes the matching braces, quotes, etc.

To enable this for a lsp server, add the following to  the
lsp server's config:
 capabilities = require('cmp_nvim_lsp').default_capabilities()
--]]

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "L3MON4d3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "windwp/nvim-autopairs",
  },
  config = function()
    local cmp = require "cmp"
    cmp.setup {
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = {
        ["<CR>"] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        ["<TAB>"] = cmp.mapping.select_next_item {
          behavior = cmp.SelectBehavior.Select,
        },
        ["<S-TAB>"] = cmp.mapping.select_prev_item {
          behavior = cmp.SelectBehavior.Select,
        },
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
      },
    }

    local npairs = require "nvim-autopairs"
    local cmp_autopairs = require "nvim-autopairs.completion.cmp"
    local ts_conds = require "nvim-autopairs.ts-conds"
    local Rule = require "nvim-autopairs.rule"
    cmp.event:on(
      "confirm_done",
      cmp_autopairs.on_confirm_done { map_char = { tex = "" } }
    )

    npairs.setup {
      check_ts = true,
    }
    npairs.add_rules {
      Rule("%", "%", "lua"):with_pair(
        ts_conds.is_ts_node { "string", "comment" }
      ),
      Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node { "function" }),
    }
  end,
}
