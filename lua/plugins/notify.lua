--=============================================================================
-------------------------------------------------------------------------------
--                                                                  NOTIFY-NVIM
--=============================================================================
-- https://github.com/rcarriga/nvim-notify
-------------------------------------------------------------------------------

--[[
Show notifications in fading popups.

Keymaps:
    - <leader>i  - show notifications history
--]]

local M = {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
}

function M.init()
  vim.keymap.set("n", "<leader>i", function()
    require("plugins.notify").history()
  end)
end

function M.config()
  local notify = require "notify"
  notify.setup {
    level = vim.log.levels.INFO,
    timeout = 2000,
    background_colour = "#000000",
  }
  vim.notify = notify
end

---Display notify history in a telescope prompt
function M.history()
  require("telescope").extensions.notify.notify(
    require("telescope.themes").get_ivy()
  )
end

return M
