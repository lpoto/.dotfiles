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
  lazy = false,
}

function M.init()
  vim.keymap.set("n", "<leader>h", function()
    Util.require("harpoon.ui", function(harpoon)
      harpoon.toggle_quick_menu()
    end)
  end)
  vim.keymap.set("n", "<C-h>", function()
    Util.require("harpoon.mark", function(harpoon)
      harpoon.add_file()
      Util.log():info "Added file to harpoon"
    end)
  end)
  for i = 0, 9 do
    vim.keymap.set("n", "<leader>" .. i, function()
      Util.require("harpoon.ui", function(harpoon)
        if i == 0 then
          harpoon.nav_next()
        else
          harpoon.nav_file(i)
        end
      end)
    end)
  end
end

function M.is_marked(bufnr)
  return Util.require("harpoon.mark", function(mark)
    return mark.status(bufnr) ~= ""
  end)
end

function M.config()
  Util.require("harpoon", function(harpoon)
    harpoon.setup {
      mark_branch = true,
    }
  end)
end

return M
