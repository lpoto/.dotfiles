--=============================================================================
-------------------------------------------------------------------------------
--                                                         TELESCOPE-UNDO-NVIM
--[[===========================================================================
https://github.com/debugloop/telescope-undo.nvim

View and search your undo tree

commands:
  - :Undo - show undo tree

keymaps:
  - "<leader>tu" - show undo tree
-----------------------------------------------------------------------------]]
local M = {
  "debugloop/telescope-undo.nvim",
  cmd = "Undo",
}

local function open_undo_picker()
  Util.require(
    "telescope",
    function(telescope) telescope.extensions.undo.undo() end
  )
end

M.keys = {
  { "<leader>tu", open_undo_picker, mode = "n" },
}

function M.init()
  vim.api.nvim_create_user_command("Undo", open_undo_picker, {})
end

function M.config()
  Util.require(
    "telescope",
    function(telescope) telescope.load_extension("undo") end
  )
end

return M
