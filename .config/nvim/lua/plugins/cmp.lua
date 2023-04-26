--=============================================================================
-------------------------------------------------------------------------------
--                                                                     NVIM-CMP
--=============================================================================
-- https://github.com/hrsh7th/nvim-cmp
--_____________________________________________________________________________

--[[
A completion engine plugin. Completion sources are installed from
external repositories, cmp-nvim-lsp,...

This also includes the vsnip plugin intergrated with cmp,
and autopairs, that autocompletes the matching braces, quotes, etc.

To enable this for a lsp server, add the following to  the
lsp server's config:
 capabilities = require('cmp_nvim_lsp').default_capabilities()

mappings:
  <Tab> - when cmp popup visible, select next item, else if
      copilot suggestion visible, accept suggestion.
  <S-Tab> - when cmp popup visible, select previous item, else if
      copilot suggestion visible, show previous expression.
  <CR> - when cmp popup visible, select current item.
  <C-x> - when cmp popup visible, close cmp popup, else if
      copilot suggestion visible, dismiss suggestion.
--]]
local M = {
  "hrsh7th/nvim-cmp",
  event = "User RealInsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
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
      {
        name = "nvim_lsp",
      },
      {
        name = "luasnip",
      },
      {
        name = "path",
      },
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
  }
end

--- Set keymaps for cmp. This is a workaround, as setting them in
--- the cmp.setup function causes them to not work when entering
--- insert mode for the first time.
---
--- Some of these mappings are shared with github copilot.
---
--- Tab - when cmp popup visible, select next item, else if
---      copilot suggestion visible, accept suggestion.
--- Shift-Tab - when cmp popup visible, select previous item, else if
---     copilot suggestion visible, show previous expression.
--- Enter - when cmp popup visible, select current item.
--- C-x - when cmp popup visible, close cmp popup, else if
---    copilot suggestion visible, dismiss suggestion.
function M.init()
  vim.keymap.set("i", "<Tab>", function()
    if package.loaded["cmp"] then
      local cmp = require "cmp"
      if cmp.visible() and #cmp.get_entries() > 1 then
        vim.schedule(function()
          cmp.select_next_item {
            behavior = cmp.SelectBehavior.Select,
            count = 1,
          }
        end)
        return
      end
    end
    return require("plugins.copilot").accept_suggestion_expression_func "<Tab>"
  end, { expr = true })

  vim.keymap.set("i", "<S-Tab>", function()
    if package.loaded["cmp"] then
      local cmp = require "cmp"
      if cmp.visible() and #cmp.get_entries() > 1 then
        vim.schedule(function()
          cmp.select_prev_item {
            behavior = cmp.SelectBehavior.Select,
            count = 1,
          }
        end)
        return
      end
    end
    return require("plugins.copilot").show_prev_expression_func "<S-Tab>"
  end, { expr = true })

  vim.keymap.set("i", "<CR>", function()
    if package.loaded["cmp"] then
      local cmp = require "cmp"
      if cmp.visible() and #cmp.get_entries() > 1 then
        vim.schedule(function()
          cmp.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }
        end)
        return
      end
    end
    return "<CR>"
  end, { expr = true })

  vim.keymap.set("i", "<C-x>", function()
    if package.loaded["cmp"] then
      local cmp = require "cmp"
      if cmp.visible() and #cmp.get_entries() > 1 then
        vim.schedule(function()
          cmp.close()
        end)
        return
      end
    end
    return require("plugins.copilot").dismiss_suggestion_expression_func "<C-x>"
  end, { expr = true })
end

return M
