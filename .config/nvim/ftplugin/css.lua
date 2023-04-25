--=============================================================================
-------------------------------------------------------------------------------
--                                                                          CSS
--[[===========================================================================
Loaded when a css file is opened
-----------------------------------------------------------------------------]]
if vim.g.ftplugin_css_loaded then
  return
end
vim.g.ftplugin_css_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"

lspconfig.start_language_server "cssls"
null_ls.register_formatter "prettier"
