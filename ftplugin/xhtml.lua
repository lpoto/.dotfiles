--=============================================================================
-------------------------------------------------------------------------------
--                                                                        XHTML
--=============================================================================
-- Loaded when a xhtml file is opened.
--_____________________________________________________________________________

local filetype = require "filetype"

filetype.config {
  filetype = "xhtml",
  priority = 0,
  copilot = true,
  formatter = function() -- npm install -g prettier
    return {
      exe = "prettier",
      args = {
        vim.api.nvim_buf_get_name(0),
      },
      stdin = true,
    }
  end,
}

filetype.load "xhtml"
