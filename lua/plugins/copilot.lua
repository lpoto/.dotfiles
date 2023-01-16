--=============================================================================
-------------------------------------------------------------------------------
--                                                               GITHUB COPILOT
--=============================================================================
-- https://github.com/github/copilot.vim
--_____________________________________________________________________________

--[[
A github copilot plugin. Uses the github copilot API to generate code.

Keymaps:
   - <C-Space> - Select the next suggestion
   - <C-k>     - show the next suggestion
   - <C-j>     - show the previous suggstion

Configure copilot with :Copilot setup
--]]

local M = {
  "github/copilot.vim",
  as = "copilot",
  cmd = "Copilot",
  init = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
  end,
}

function M.config()
  vim.api.nvim_set_keymap(
    "i",
    "<C-Space>",
    'copilot#Accept("<CR>")',
    { silent = true, expr = true }
  )
  vim.api.nvim_set_keymap(
    "i",
    "<C-k>",
    "copilot#Next()",
    { silent = true, expr = true }
  )
  vim.api.nvim_set_keymap(
    "i",
    "<C-j>",
    "copilot#Previous()",
    { silent = true, expr = true }
  )
end

return M
