--=============================================================================
-------------------------------------------------------------------------------
--                                                                 SIDEBAR-NVIM
--=============================================================================
-- https://github.com/sidebar-nvim/sidebar.nvim
--_____________________________________________________________________________
--[[
display files, git status and docker containers in a sidebar.

Keymaps:
  - "<leader>s" - Toggle sidebar

(use c - create, y - copy, d - delete, ... keymaps in files )
(use s - stage, u - unstage, e - edit, ... keymaps in git )
]]

local M = {
  "sidebar-nvim/sidebar.nvim",
}

function M.init()
  vim.keymap.set("n", "<leader>s", function()
    require("sidebar-nvim").toggle()
  end)
end

function M.config()
  local sidebar = require "sidebar-nvim"
  sidebar.setup {
    open = false,
    --hide_statusline = true,
    side = "right",
    sections = { "files", "git", "containers" },
    update_interval = 5000,
  }
end

return M
