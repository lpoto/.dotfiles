--=============================================================================
-------------------------------------------------------------------------------
--                                                               GITHUB COPILOT
--=============================================================================
-- https://github.com/github/copilot.vim
--_____________________________________________________________________________

local M = {}

---The init function for the github copilot.
---This disables the default tab mapping for the plugin.
---It will rather map:
---  <C-Space> to select the next suggestion.
---  <C-k> to show the next suggestion.
---  <C-j> to show the previous suggestion.
function M.init()
  vim.g.copilot_no_tab_map = true
  vim.g.copilot_assume_mapped = true
  M.remappings()
end

---This maps:
---  <C-Space> to select the next suggestion.
---  <C-k> to show the next suggestion.
---  <C-j> to show the previous suggestion.
function M.remappings()
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
