--=============================================================================
-------------------------------------------------------------------------------
--                                                                   TYPESCRIPT
--=============================================================================
-- Loaded when a typescript file is opened.
--_____________________________________________________________________________

local filetype = require "filetype"

filetype.config {
  filetype = "typescript", -- npm install -g typescript
  priority = 1,
  copilot = true,
  lsp_server = "tsserver", -- npm install -g typescript-language-server
  linter = "eslint", -- npm install -g eslint
  formatter = function()
    return {
      exe = "prettier", -- npm install -g prettier
      args = { vim.api.nvim_buf_get_name(0) },
      stdin = true,
    }
  end,
}

filetype.load "typescript"
