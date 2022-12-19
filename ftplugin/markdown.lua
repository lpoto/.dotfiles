--=============================================================================
-------------------------------------------------------------------------------
--                                                                     MARKDOWN
--=============================================================================
-- Loaded when a markdown file is opened.
--_____________________________________________________________________________

local filetype = require "filetype"

filetype.config {
  filetype = "markdown",
  priority = 0,
  copilot = true,
  -- npm install -g prettier
  formatter = function()
    return {
      exe = "prettier",
      args = {
        vim.api.nvim_buf_get_name(0),
      },
      stdin = true,
    }
  end,
}

filetype.load "markdown"
