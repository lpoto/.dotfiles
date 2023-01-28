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

function M.init()
  vim.keymap.set("n", "<leader>ha", function()
    require("harpoon.mark").add_file()
  end)
  vim.keymap.set("n", "<leader>h", function()
    require("harpoon.ui").toggle_quick_menu()
  end)
  for i, v in ipairs { "q", "w", "e", "r", "t" } do
    vim.keymap.set("n", "<leader>h" .. v, function()
      require("harpoon.ui").nav_file(i)
    end)
  end
end

function M.config() end

return M
