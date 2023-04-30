--=============================================================================
-------------------------------------------------------------------------------
--                                                                         HTML
--[[===========================================================================
Loaded when a html file is opened
-----------------------------------------------------------------------------]]
if vim.g.ftplugin_html_loaded then
  return
end
vim.g.ftplugin_html_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"

lspconfig.start_language_server "html"
null_ls.register_formatter "prettier"
