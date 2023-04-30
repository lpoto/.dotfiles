--=============================================================================
-------------------------------------------------------------------------------
--                                                                   TYPESCRIPT
--[[===========================================================================
Loaded when a typescript file is opened
-----------------------------------------------------------------------------]]
if vim.g.ftplugin_typescript_loaded then
  return
end
vim.g.ftplugin_typescript_loaded = true

local lspconfig = require "plugins.lspconfig"
lspconfig.start_language_server "tsserver"

local null_ls = require "plugins.null-ls"
null_ls.register_formatter "prettier"
