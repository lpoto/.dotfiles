--=============================================================================
-------------------------------------------------------------------------------
--                                                  TELESCOPE-FILE-BROWSER-NVIM
--=============================================================================
-- https://github.com/nvim-telescope/telescope-file-browser.nvim
--_____________________________________________________________________________

--[[
A telescope file browser

Keymaps:
  - "<leader>tb" - Open the file browser
--]]

local M = {
  "nvim-telescope/telescope-file-browser.nvim",
}

function M.init()
  vim.keymap.set("n", "<leader>tb", function()
    require("telescope").extensions.file_browser.file_browser()
  end)
end

function M.config()
  local telescope = require "telescope"
  telescope.setup {
    extensions = {
      file_browser = {
        theme = "ivy",
        hidden = true,
        hijack_netrw = true,
      },
    },
  }

  telescope.load_extension "file_browser"
end

return M
