--=============================================================================
-------------------------------------------------------------------------------
--                                                                     NVIM-CMP
--=============================================================================
-- https://github.com/hrsh7th/nvim-cmp
--_____________________________________________________________________________

local cmp = require("util.packer.wrapper").get "cmp"

---Default setup for cmp plugin.
---Cmp is mostly used with lspconfig
cmp:config(function()
  local cmp_module = require "cmp"
  cmp_module.setup {
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = {
      ["<CR>"] = cmp_module.mapping.confirm {
        behavior = cmp_module.ConfirmBehavior.Replace,
        select = true,
      },
      ["<TAB>"] = cmp_module.mapping.select_next_item {
        behavior = cmp_module.SelectBehavior.Select,
      },
      ["<S-TAB>"] = cmp_module.mapping.select_prev_item {
        behavior = cmp_module.SelectBehavior.Select,
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
  cmp_module.event:on(
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
end)
