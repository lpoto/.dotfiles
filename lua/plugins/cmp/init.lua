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

local M = {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4d3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    require "plugins.cmp.autopairs",
    require "plugins.cmp.copilot",
  },
}

function M.init()
  local id
  id = vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
      if buftype:len() == "" then
        vim.api.nvim_del_autocmd(id)
        M.config()
      end
    end,
  })
end

function M.config()
  local cmp = require "cmp"

  cmp.setup {
    completion = {
      completeopt = "menu,menuone,noinsert",
    },
    preselect = cmp.PreselectMode.Item,
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
      { name = "nvim_lsp", group_index = 2 },
      { name = "luasnip", group_index = 2 },
      { name = "buffer", group_index = 2 },
      { name = "path", group_index = 2 },
      { name = "copilot", group_index = 2 },
    },

    sorting = {
      priority_weight = 0,
      comparators = {
        -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
        cmp.config.compare.exact,
        require("copilot_cmp.comparators").prioritize,
        require("copilot_cmp.comparators").score,
        -- Below is the default comparitor list and order for nvim-cmp
        cmp.config.compare.offset,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.locality,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    formatting = {
      insert_text = require("copilot_cmp.format").remove_existing,
    },
  }
end

return M
