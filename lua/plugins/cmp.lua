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
  },
}

function M.init()
  local loaded = false
  vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
      vim.schedule(function()
        if not loaded then
          local buf = vim.api.nvim_get_current_buf()
          local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
          if buftype:len() == 0 then
            M.config()
            loaded = true
          end
        end

        local cmp = require "cmp"
        for _, source in pairs(cmp.core.sources) do
          if source.name == "copilot" then
            source:complete(
              cmp.core:get_context { reason = cmp.ContextReason.Manual },
              function() end
            )
          end
        end
      end)
    end,
  })
end

function M.config()
  local cmp = require "cmp"

  cmp.setup {
    completion = {
      completeopt = "menu,menuone,noinsert",
      --autocomplete = true,
      --keyword_length = 1,
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
      {
        name = "nvim_lsp",
        group_index = 2, --[[  keyword_length =  1]]
      },
      {
        name = "luasnip",
        group_index = 2, --[[  keyword_length =  1]]
      },
      {
        name = "buffer",
        group_index = 2, --[[  keyword_length =  1]]
      },
      {
        name = "path",
        group_index = 2, --[[ keyword_length = 1  ]]
      },
      {
        name = "copilot",
        group_index = 2, --[[ keyword_length = 0  ]]
      },
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
