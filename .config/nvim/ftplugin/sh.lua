--=============================================================================
-------------------------------------------------------------------------------
--                                                                           SH
--[[===========================================================================
Loaded when a sh file is opened
-----------------------------------------------------------------------------]]

if vim.g.ftplugin_sh_loaded then
  return
end
vim.g.ftplugin_sh_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"

lspconfig.start_language_server "bashls"
null_ls.register_formatter "shfmt"
