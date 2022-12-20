--=============================================================================
-------------------------------------------------------------------------------
--                                                                        XHTML
--=============================================================================
-- Loaded when a xhtml file is opened.
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
  filetype = "xhtml",
  priority = 1,
  copilot = true,
  formatter = "prettier",
  language_server = "html",
}

filetype.load "xhtml"
