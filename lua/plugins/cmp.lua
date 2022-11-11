--=============================================================================
-------------------------------------------------------------------------------
--                                                                     NVIM-CMP
--=============================================================================
-- https://github.com/hrsh7th/nvim-cmp
--_____________________________________________________________________________

local M = {}

---Return default capabilities that include cmp capabilities
---to use in the lspconfig's server configs
---@return table
function M.default_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return require("cmp_nvim_lsp").default_capabilities(capabilities)
end

---Default setup for cmp plugin.
---Cmp is mostly used with lspconfig
function M.setup()
  local cmp = require "cmp"
  cmp.setup {
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = {
      ["<C-j>"] = cmp.mapping.scroll_docs(-4),
      ["<C-k>"] = cmp.mapping.scroll_docs(4),
      ["<C-e>"] = cmp.mapping.close(),
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
end

return M
