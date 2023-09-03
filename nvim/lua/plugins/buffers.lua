--=============================================================================
-------------------------------------------------------------------------------
--                                                                 BUFFERS.NVIM
--[[===========================================================================
https://github.com/lpoto/buffers.nvim

Keep only a limited number of buffers loaded and listed.

Commands:

  :Buffers clean  - Clean unloaded and unlisted buffers
-----------------------------------------------------------------------------]]
local M = {
  "lpoto/buffers.nvim",
  opts = {},
  event = { "BufRead", "BufNewFile" },
}

return M
