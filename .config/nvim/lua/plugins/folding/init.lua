--=============================================================================
-------------------------------------------------------------------------------
--                                                                      FOLDING
--=============================================================================
-- Fold or unfold the current context with <CR>
--_____________________________________________________________________________

local M = {
  dir = table.concat(
    { vim.fn.stdpath "config", "lua", "plugins", "folding" },
    "/"
  ),
  event = "VeryLazy",
}

function M.config()
  local folding = require "folding"
  folding.config()
end

return M
