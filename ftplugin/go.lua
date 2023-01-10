--=============================================================================
-------------------------------------------------------------------------------
--                                                                           GO
--=============================================================================
-- Loaded when a Go file is opened.
-- Install required servers, linters and formatters with:
--
--                        :MasonInstall <pkg>
--
-- To see available linters and formatters for current filetype, run:
--
--                        :NullLsInfo
--
-- To see attached language server for current filetype, run:
--
--                        :LspInfo
--_____________________________________________________________________________

local filetype = require "config.filetype"

filetype.config {
  filetype = "go",
  priority = 1,
  copilot = true,
  language_server = "gopls",
  formatter = "goimports",
  --linter = "golangci_lint",
}

filetype.load "go"
