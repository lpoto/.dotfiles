--=============================================================================
-------------------------------------------------------------------------------
--                                                                 HARPOON.NVIM
--[[===========================================================================
Mark files easily navigate between them.

Keymaps:
  - "<leader>h"   - toggle quick menu
  - "<C-h>"       - mark file
  - "<leader>1-9" - navigate to marked file
  - "<leader>0"   - navigate to next marked file

-----------------------------------------------------------------------------]]
local M = {
  "ThePrimeagen/harpoon",
}

local toggle_harpoon_quick_menu
local mark_file_with_harpoon
local navigate_to_harpoon_marked_file

function M.init()
  -- NOTE: set keymaps in the init functions so that they
  -- will load the plugin (if it is not loaded yet) when used
  vim.keymap.set("n", "<leader>h", toggle_harpoon_quick_menu)
  vim.keymap.set("n", "<C-h>", mark_file_with_harpoon)
  for i = 0, 9 do
    vim.keymap.set("n", "<leader>" .. i, function()
      navigate_to_harpoon_marked_file(i, i == 0)
    end)
  end
end

function M.config()
  Util.require("harpoon", function(harpoon)
    harpoon.setup {
      -- Separate marks based on git branch
      mark_branch = true,
    }
  end)
end

---Check whether the file loaded in the buffer identified
---by the provided buffer number is marked with harpoon.
---@param bufnr number
---@return boolean
function M.is_marked(bufnr)
  if type(bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  return Util.require("harpoon.mark", function(mark)
    return mark.status(bufnr) ~= ""
  end) or false
end

function toggle_harpoon_quick_menu()
  Util.require("harpoon.ui", function(harpoon)
    harpoon.toggle_quick_menu()
    if vim.bo.filetype == "harpoon" then
      vim.wo.number = true
    end
  end)
end

function mark_file_with_harpoon()
  Util.require("harpoon.mark", function(harpoon)
    harpoon.add_file()
    Util.log():info "Added file to harpoon"
  end)
end

function navigate_to_harpoon_marked_file(i, goto_next)
  Util.require("harpoon.ui", function(harpoon)
    if goto_next then
      harpoon.nav_next()
    else
      harpoon.nav_file(i)
    end
  end)
end

return M
