--=============================================================================
--                                          https://github.com/hrsh7th/nvim-cmp
--[[===========================================================================

A completion engine plugin. Completion sources are installed from
external repositories, cmp-nvim-lsp,...

-----------------------------------------------------------------------------]]

local M = {
  "hrsh7th/nvim-cmp",
  event = { "BufRead", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
  },
}

function M.config()
  local cmp = require "cmp"
  ---@diagnostic disable-next-line: missing-fields
  cmp.setup {
    ---@diagnostic disable-next-line: missing-fields
    completion = {
      completeopt = "menu,menuone,noinsert,noselect",
    },
    snippet = {
      expand = function(args) vim.snippet.expand(args.body) end,
    },
    sources = {
      { name = "nvim_lsp" },
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
      ["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },
      ["<TAB>"] = cmp.mapping.select_next_item(),
      ["<S-TAB>"] = cmp.mapping.select_prev_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(4),
      ["<C-u>"] = cmp.mapping.scroll_docs(-4),
      ["<C-x>"] = cmp.mapping.close()
    },
  }
end

return M
