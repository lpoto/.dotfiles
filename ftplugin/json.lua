--=============================================================================
-------------------------------------------------------------------------------
--                                                                         JSON
--[[===========================================================================
Loaded when a json file is opened
-----------------------------------------------------------------------------]]
if vim.g.ftplugin_json_loaded then
  return
end
vim.g.ftplugin_json_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"

lspconfig.start_language_server "jsonls"
null_ls.register_formatter "prettier"
