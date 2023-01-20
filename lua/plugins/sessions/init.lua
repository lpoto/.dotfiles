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
  event = {"VeryLazy", "VimLeavePre"},
}

function M.init()
  vim.api.nvim_create_user_command("Sessions", function()
    local sessions = require "sessions"
    sessions.list_sessions()
  end, {})
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
      vim.api.nvim_exec("delc! SessionSave", true)
      vim.api.nvim_exec("delc! SessionLoad", true)
      vim.api.nvim_exec("delc! SessionDelete", true)
    end,
  })
end

function M.config()
  local sessions = require "sessions"
  sessions.config()
end

return M
