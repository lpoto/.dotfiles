--=============================================================================
-------------------------------------------------------------------------------
--                                                                          PHP
--[[===========================================================================
Loaded when a php file is opened
-----------------------------------------------------------------------------]]
if vim.g.ftplugin_php_loaded then
  return
end
vim.g.ftplugin_php_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"

null_ls.register_formatter "phpcbf"

lspconfig.start_language_server("phpactor", {
  root_dir = function()
    local f = vim.fs.find({
      ".git",
      "composer.json",
      "composer.lock",
      "vendor",
    }, { upward = true })
    if not f or not next(f) then
      return vim.fn.getcwd()
    end
    return vim.fs.dirname(f[1])
  end,
})
