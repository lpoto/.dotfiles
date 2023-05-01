--=============================================================================
-------------------------------------------------------------------------------
--                                                                        OCAML
--[[===========================================================================
Loaded when a ocaml file is opened
-----------------------------------------------------------------------------]]
if vim.g.ftplugin_ocaml_loaded then
  return
end
vim.g.ftplugin_ocaml_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"

lspconfig.start_language_server "ocamllsp"
null_ls.register_formatter "ocamlformat"
