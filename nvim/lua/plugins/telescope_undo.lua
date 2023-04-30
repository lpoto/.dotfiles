--=============================================================================
-------------------------------------------------------------------------------
--                                                         TELESCOPE-UNDO-NVIM
--=============================================================================
-- https://github.com/debugloop/telescope-undo.nvim
--_____________________________________________________________________________

--[[
View and search your undo tree

commands:
  - :Undo - show undo tree
--]]

local M = {
  "debugloop/telescope-undo.nvim",
  cmd = "Undo",
}

function M.init()
  vim.api.nvim_create_user_command("Undo", function()
    require("telescope").extensions.undo.undo()
  end, {})
end

function M.config()
  local telescope = require "telescope"
  local themes = require "telescope.themes"
  telescope.setup {
    extensions = {
      undo = themes.get_ivy(),
    },
  }

  telescope.load_extension "undo"
end

return M
