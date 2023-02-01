--=============================================================================
-------------------------------------------------------------------------------
--                                                                           GO
--[[===========================================================================
Loaded when a go file is opened
-----------------------------------------------------------------------------]]

if vim.g.ftplugin_go_loaded then
  return
end
vim.g.ftplugin_go_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"

lspconfig.start_language_server "gopls"
null_ls.register_linter "golangci_lint"
null_ls.register_formatter "goimports"
