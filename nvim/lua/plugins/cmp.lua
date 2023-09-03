--=============================================================================
-------------------------------------------------------------------------------
--                                                                     NVIM-CMP
--[[===========================================================================
https://github.com/hrsh7th/nvim-cmp
A completion engine plugin. Completion sources are installed from
external repositories, cmp-nvim-lsp,...

This also includes the vsnip plugin intergrated with cmp,
and autopairs, that autocompletes the matching braces, quotes, etc.

-----------------------------------------------------------------------------]]
local M = {
  "hrsh7th/nvim-cmp",
  tag = "v0.0.1",
  event = { "BufRead", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "L3MON4d3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
}

local set_confirm_keymap

function M.config()
  local _, cmp = pcall(require, "cmp")
  if type(cmp) ~= "table" then return end
  cmp.setup({
    completion = {
      completeopt = "menu,menuone,noinsert,noselect",
    },
    snippet = {
      expand = function(args) require("luasnip").lsp_expand(args.body) end,
    },
    sources = {
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "path" },
      { name = "buffer" },
    },
    window = {
      completion = cmp.config.window.bordered({
        winhighlight = "NormalFloat:WinSeparator,FloatBorder:WinSeparator",
      }),
      documentation = cmp.config.window.bordered({
        winhighlight = "NormalFloat:WinSeparator,FloatBorder:WinSeparator",
      }),
    },
    preselect = cmp.PreselectMode.None,
    mapping = cmp.mapping.preset.insert({
      ["<TAB>"] = cmp.mapping.select_next_item(),
      ["<S-TAB>"] = cmp.mapping.select_prev_item(),
      ["<C-x>"] = cmp.mapping.close(),
      ["<C-d>"] = cmp.mapping.scroll_docs(4),
      ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    }),
  })
  set_confirm_keymap()
end

--- If copilot suggestion is visible and cmp has no selected entry,
--- <CR> will accept suggestion, otherwise if there is no
--- copilot suggestion and cmp is visible, <CR> will select
--- the first cmp entry, otherwise <CR> will just do
--- its default behavior.
function set_confirm_keymap()
  vim.keymap.set("i", "<CR>", function()
    local ok, suggestion = pcall(require, "copilot.suggestion")
    if not ok then return "<CR>" end
    local cmp
    ok, cmp = pcall(require, "cmp")
    if not ok then return "<CR>" end
    if
      cmp
      and (
        cmp.visible() and cmp.get_selected_entry() ~= nil
        or cmp.visible() and (not suggestion or not suggestion.is_visible())
      )
    then
      vim.defer_fn(function() cmp.confirm({ select = true }) end, 5)
      return true
    end
    if suggestion and suggestion.is_visible() then
      vim.defer_fn(function() suggestion.accept() end, 5)
      return true
    end
    return "<CR>"
  end, { expr = true, remap = true })
end

return M
