--=============================================================================
-------------------------------------------------------------------------------
--                                                                     MARKDOWN
--[[===========================================================================
Loaded when a markdown file is opened
-----------------------------------------------------------------------------]]
if vim.g.ftplugin_markdown_loaded then
  return
end
vim.g.ftplugin_markdown_loaded = true

--local lspconfig = require("plugins.lspconfig")
--lspconfig.start_language_server("marksman")

local null_ls = require "plugins.null-ls"
null_ls.register_formatter "prettier"
