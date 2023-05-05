--=============================================================================
-------------------------------------------------------------------------------
--                                                                    SIMPLEBAR
--=============================================================================
-- https://github.com/lpoto/simplebar.nvim
--[[___________________________________________________________________________
Disable statusline and show all needed information in the winbar.
-----------------------------------------------------------------------------]]
local M = {
  "lpoto/simplebar.nvim",
  event = "User RealBufEnter",
}

M.config = function()
  require("simplebar").setup {
    disable_statusline = true,
  }
end

return M
