--=============================================================================
-------------------------------------------------------------------------------
--                                                                     NVIM-CMP
--=============================================================================
-- https://github.com/hrsh7th/nvim-cmp
--_____________________________________________________________________________

require("plugin").new {
  "hrsh7th/nvim-cmp",
  as = "cmp",
  requires = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/vim-vsnip",
    "windwp/nvim-autopairs",
  },
  config = function(cmp)
    cmp.setup {
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
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
        { name = "vsnip" },
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
      ts_config = {
        lua = { "string" },
        -- it will not add a pair on that treesitter node
        javascript = { "template_string" },
      },
    }
    npairs.add_rules {
      Rule("%", "%", "lua"):with_pair(
        ts_conds.is_ts_node { "string", "comment" }
      ),
      Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node { "function" }),
    }
  end,
}
