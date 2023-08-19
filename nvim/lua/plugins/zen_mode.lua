--=============================================================================
-------------------------------------------------------------------------------
--                                                                ZEN_MODE.NVIM
--[[===========================================================================
https://github.com/folke/zen-mode.nvim

Focus the current window and remove all disctractions

Keymaps:
  - "<leader>z"  - toggle zen mode
-----------------------------------------------------------------------------]]
local M = {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  keys = {
    {
      "<leader>z",
      function() vim.api.nvim_exec("ZenMode", false) end,
      mode = "n",
    },
  },
  opts = {
    window = {
      width = 160,
    },
  },
}

return M
