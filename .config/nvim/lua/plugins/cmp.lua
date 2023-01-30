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
--echo hello world

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
  local id
  id = vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
      if M.cond == false or type(M.cond) == "function" and not M.cond() then
        vim.api.nvim_del_autocmd(id)
        return
      end
      vim.schedule(function()
        local buf = vim.api.nvim_get_current_buf()
        local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
        if buftype:len() == 0 then
          vim.api.nvim_del_autocmd(id)
          M.config()
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
        group_index = 2,
      },
      {
        name = "luasnip",
        group_index = 2,
      },
      {
        name = "buffer",
        group_index = 2,
      },
      {
        name = "path",
        group_index = 2,
      },
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
  }
  vim.api.nvim_exec_autocmds("User", {
    pattern = "CmpLoaded",
  })
end

return M
