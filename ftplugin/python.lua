--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PYTHON
--[[===========================================================================
Loaded when a python file is opened
-----------------------------------------------------------------------------]]

if vim.g.ftplugin_python_loaded then
  return
end
vim.g.ftplugin_python_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"

lspconfig.start_language_server "pylsp"
null_ls.register_linter "flake8"
null_ls.register_formatter "autopep8"
