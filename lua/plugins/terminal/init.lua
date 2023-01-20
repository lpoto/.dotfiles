--=============================================================================
-------------------------------------------------------------------------------
--                                                                     TERMINAL
--=============================================================================
--[[ Toggling terminal

Keymaps:
  - <C-t> - toggle terminal
-----------------------------------------------------------------------------]]

local M = {
  dir = table.concat(
    { vim.fn.stdpath "config", "lua", "plugins", "terminal" },
    "/"
  ),
}

function M.init()
  vim.keymap.set("n", "<C-t>", function()
    local terminal = require "terminal"
    terminal.toggle()
  end)
end

return M
