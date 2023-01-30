--=============================================================================
-------------------------------------------------------------------------------
--                                                                     SESSIONS
--=============================================================================
--[[
Automated session management.

Commands:
  - :Sessions - Display all available sessions

NOTE: session is saved automatically when yout quit neovim.
-----------------------------------------------------------------------------]]

local M = {
  dir = table.concat(
    { vim.fn.stdpath "config", "lua", "plugins", "sessions" },
    "/"
  ),
  event = { "VimLeavePre" },
}

function M.init()
  vim.api.nvim_create_user_command("Sessions", function()
    local sessions = require "sessions"
    sessions.list_sessions()
  end, {})
  vim.keymap.set("n", "<leader>s", "<cmd>Sessions<CR>")
end

function M.config()
  local sessions = require "sessions"
  sessions.config()
end

return M
