--=============================================================================
-------------------------------------------------------------------------------
--                                                                            C
--[[===========================================================================
Loaded when a c file is opened
-----------------------------------------------------------------------------]]
if vim.g.ftplugin_c_loaded then
  return
end
vim.g.ftplugin_c_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"

lspconfig.start_language_server "clangd"
null_ls.register_formatter "clang_format"
