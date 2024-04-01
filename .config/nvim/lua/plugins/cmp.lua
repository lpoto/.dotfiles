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

local set_close_keymap
local set_confirm_keymap

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
      ["<TAB>"] = cmp.mapping.select_next_item(),
      ["<S-TAB>"] = cmp.mapping.select_prev_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(4),
      ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    },
  }
  set_confirm_keymap()
  set_close_keymap()
end

--- If copilot suggestion is visible and cmp has no selected entry,
--- <CR> will accept suggestion, otherwise if there is no
--- copilot suggestion and cmp is visible, <CR> will select
--- the first cmp entry, otherwise <CR> will just do
--- its default behavior.
function set_confirm_keymap()
  vim.keymap.set("i", "<CR>", function()
    local has_suggestion, suggestion = pcall(require, "copilot.suggestion")
    local ok, cmp = pcall(require, "cmp")
    if not ok then return "<CR>" end
    if
      cmp.visible()
      and (
        cmp.get_selected_entry() ~= nil
        or not has_suggestion
        or not suggestion.is_visible()
      )
    then
      print("ENTRY", vim.inspect(cmp.get_selected_entry()))
      print("IS NIL", cmp.get_selected_entry() == nil)
      vim.defer_fn(function() cmp.confirm { select = true } end, 5)
      return true
    end
    if has_suggestion and suggestion.is_visible() then
      vim.defer_fn(function() suggestion.accept() end, 5)
      return true
    end
    return "<CR>"
  end, { expr = true })
end

--- If cmp is visible, <C-x> will close cmp, otherwise if
--- copilot suggestion is visible, <C-x> will dismiss
--- suggestion, otherwise <C-x> will just do its default
--- behavior.
function set_close_keymap()
  vim.keymap.set("i", "<C-x>", function()
    local ok, cmp = pcall(require, "cmp")
    if ok then
      if cmp.visible() then
        vim.schedule(function() cmp.close() end)
        return true
      end
    end
    local suggestion
    ok, suggestion = pcall(require, "copilot.suggestion")
    if ok and suggestion.is_visible() then
      vim.schedule(function() suggestion.dismiss() end)
      return true
    end
    return "<C-x>"
  end, { expr = true })
end

return M
