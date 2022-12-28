return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  config = function()
    local notify = require "notify"
    notify.setup {
      level = vim.log.levels.INFO,
      timeout = 3000,
      background_colour = "#000000",
    }
    vim.notify = notify
  end,
}
