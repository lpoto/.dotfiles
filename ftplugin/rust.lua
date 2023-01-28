--=============================================================================
-------------------------------------------------------------------------------
--                                                                       RUST
--[[===========================================================================
Loaded when a rust file is opened
-----------------------------------------------------------------------------]]

if vim.g.ftplugin_rust_loaded then
  return
end
vim.g.ftplugin_rust_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"

lspconfig.start_language_server "rust_analyzer"
null_ls.register_formatter "rustfmt"
