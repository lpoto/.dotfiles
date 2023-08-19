--=============================================================================
-------------------------------------------------------------------------------
--                                                         TELESCOPE-UNDO-NVIM
--[[===========================================================================
https://github.com/debugloop/telescope-undo.nvim

View and search your undo tree

commands:
  - :Undo - show undo tree
-----------------------------------------------------------------------------]]
local M = {
  "debugloop/telescope-undo.nvim",
  cmd = "Undo",
}

function M.init()
  vim.api.nvim_create_user_command("Undo", function()
    Util.require(
      "telescope",
      function(telescope) telescope.extensions.undo.undo() end
    )
  end, {})
end

function M.config()
  Util.require(
    "telescope",
    function(telescope) telescope.load_extension("undo") end
  )
end

return M
