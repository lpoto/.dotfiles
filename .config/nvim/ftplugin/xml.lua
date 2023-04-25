--=============================================================================
-------------------------------------------------------------------------------
--                                                                          XML
--[[===========================================================================
Loaded when a xml file is opened
-----------------------------------------------------------------------------]]
if vim.g.ftplugin_xml_loaded then
  return
end
vim.g.ftplugin_xml_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"

lspconfig.start_language_server "lemminx"
null_ls.register_formatter "prettier"
