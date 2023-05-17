--=============================================================================
-------------------------------------------------------------------------------
--                                                       TELESCOPE-FILE_BROWSER
--[[===========================================================================
https://github.com/nvim-telescope/telescope-file-browser.nvim

Keymaps:
 - "<leader>N"   - file browser relative to current file
 - "<C-n>"       - file browser relative to current directory

-----------------------------------------------------------------------------]]
local M = {
  "nvim-telescope/telescope-file-browser.nvim",
}

function M.file_browser()
  require("telescope").extensions.file_browser.file_browser()
end

function M.relative_file_browser()
  require("telescope").extensions.file_browser.file_browser {
    path = "%:p:h",
  }
end

M.keys = {
  { "<leader>N", M.relative_file_browser, mode = "n" },
  { "<C-n>", M.file_browser, mode = "n" },
}

function M.config()
  local telescope = require "telescope"
  telescope.setup {
    extensions = {
      file_browser = {
        theme = "ivy",
        hidden = true,
        initial_mode = "normal",
        hijack_netrw = true,
        no_ignore = true,
        grouped = true,
        file_ignore_patterns = {},
        dir_icon = "",
        respect_gitignore = false,
      },
    },
  }

  telescope.load_extension "file_browser"
end

return M
