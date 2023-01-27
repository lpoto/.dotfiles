--=============================================================================
-------------------------------------------------------------------------------
--                                                                 COMMENT.NVIM
--=============================================================================
-- https://github.com/numToStr/Comment.nvim
--_____________________________________________________________________________

--[[
Smart and powerful comment plugin.

Keymaps:
 normal:
  `gcc` - Toggles the current line using linewise comment
  `gbc` - Toggles the current line using blockwise comment
  `[count]gcc` - Toggles the number of line given as a prefix-count (linewise)
  `[count]gbc` - Toggles the number of line given as a prefix-count (blockwise)
  `gc[count]{motion}` - (Op-pending) Toggles the region using linewise comment
  `gb[count]{motion}` - (Op-pending) Toggles the region using blockwise commen

 visual:
  `gc` - Toggles the region using linewise comment
  `gb` - Toggles the region using blockwise comment
]]

return {
  "numToStr/Comment.nvim",
  event = "ModeChanged *:[vV\x16]*",
  keys = "gc",

  config = function()
    require("Comment").setup()
  end,
}
