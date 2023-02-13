--=============================================================================
-------------------------------------------------------------------------------
--                                                                      HARPOON
--=============================================================================
-- https://github.com/ThePrimeagen/harpoon
--[[___________________________________________________________________________

Navigate to common files. 

Keymaps:
  -  <leader> ha  - Mark file
  -  <leader> h   - Toggle quick menu
  - <leader> hq   - Jump to fist marked file
  - <leader> hw   - Jump to second marked file
  -    ... he, hr, ht

------------------------------------------------------------------------------]]

local M = {
  "ThePrimeagen/harpoon",
}

M.keys = {
  {
    "<leader>ha",
    function()
      require("harpoon.mark").add_file()
    end,
    mode = "n",
  },
  {
    "<leader>h",
    function()
      require("harpoon.ui").toggle_quick_menu()
    end,
  },
  mode = "n",
}

for i, v in ipairs { "q", "w", "e", "r", "t" } do
  table.insert(M.keys, {
    "<leader>h" .. v,
    function()
      require("harpoon.ui").nav_file(i)
    end,
    mode = "n",
  })
end

return M
