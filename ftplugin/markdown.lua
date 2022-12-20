--=============================================================================
-------------------------------------------------------------------------------
--                                                                     MARKDOWN
--=============================================================================
-- Loaded when a markdown file is opened.
-- Install required servers, linters and formatters with:
--
--                        :MasonInstall <pkg>  (or :Mason)
--
-- To see available linters and formatters for current filetype, run:
--
--                        :NullLsInfo
--
-- To see attached language server for current filetype, run:
--
--                        :LspInfo
--_____________________________________________________________________________

local filetype = require "filetype"

filetype.config {
  filetype = "markdown",
  priority = 0,
  copilot = true,
  formatter = "prettier",
}

filetype.load "markdown"
