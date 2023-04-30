--=============================================================================
-------------------------------------------------------------------------------
--                                                                         YAML
--[[===========================================================================
Loaded when a yaml file is opened
-----------------------------------------------------------------------------]]
if vim.g.ftplugin_yaml_loaded then
  return
end
vim.g.ftplugin_yaml_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"

lspconfig.start_language_server("yamlls", {
  settings = {
    yaml = {
      keyOrdering = false,
    },
  },
})
null_ls.register_formatter "yamlfmt"
