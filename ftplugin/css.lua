--=============================================================================
-------------------------------------------------------------------------------
--                                                                           CSS
--=============================================================================
-- Loaded when a css file is opened.
-- Install required servers, linters and formatters with:
--
--                        :MasonInstall <pkg>   (or :Mason)
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
  filetype = "css",
  priority = 0,
  copilot = true,
  formatter = "prettier",
  language_server = "cssls",
}

filetype.load "css"
