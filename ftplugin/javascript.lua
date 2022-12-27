--=============================================================================
-------------------------------------------------------------------------------
--                                                                   JACASCRIPT
--=============================================================================
-- Loaded when a javascript file is opened.
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

local filetype = require "config.filetype"

filetype.config {
  filetype = "javascript",
  priority = 1,
  copilot = true,
  language_server = "tsserver",
  formatter = "prettier",
}

filetype.load "javascript"
