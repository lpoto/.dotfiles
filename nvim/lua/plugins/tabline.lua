--=============================================================================
-------------------------------------------------------------------------------
--                                                                 TABLINE.NVIM
--[[===========================================================================
https://github.com/lpoto/tabline.nvim

Disables statusline completely and always displays the tabline, like a winbar,
but global.

-----------------------------------------------------------------------------]]
local M = {
  "lpoto/tabline.nvim",
  event = "User LazyVimStarted",
  opts = {
    hide_statusline = true,
  },
}

return M
