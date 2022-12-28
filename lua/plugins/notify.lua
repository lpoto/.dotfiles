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

return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  config = function()
    local notify = require "notify"
    notify.setup {
      level = vim.log.levels.INFO,
      timeout = 2000,
      background_colour = "#000000",
    }
    vim.notify = notify

    local mapper = require "util.mapper"
    mapper.map(
      "n",
      "<leader>i",
      "<cmd>lua require('telescope').extensions.notify.notify()<CR>"
    )
  end,
}
