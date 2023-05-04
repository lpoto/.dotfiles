--=============================================================================
-------------------------------------------------------------------------------
--                                                       TELESCOPE-FILE_BROWSER
--=============================================================================
-- https://github.com/nvim-telescope/telescope-file-browser.nvim
--_____________________________________________________________________________
--[[

Keymaps:
 - "<leader>N"   - file browser relative to current file
 - "<C-n>"       - file browser relative to current directory

--]]
local M = {
  "nvim-telescope/telescope-file-browser.nvim",
}

M.keys = {
  {
    "<leader>N",
    function()
      require("telescope").extensions.file_browser.file_browser {
        path = "%:p:h",
      }
    end,
    mode = "n",
  },
  {
    "<C-n>",
    function()
      require("telescope").extensions.file_browser.file_browser()
    end,
    mode = "n",
  },
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
        respect_gitignore = false,
      },
    },
  }

  telescope.load_extension "file_browser"
end

return M
