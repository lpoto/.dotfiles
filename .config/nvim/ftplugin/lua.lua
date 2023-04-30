--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LUA
--[[===========================================================================
Loaded when a lua file is opened
-----------------------------------------------------------------------------]]
if vim.g.ftplugin_lua_loaded then
  return
end
vim.g.ftplugin_lua_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"
local util = require "config.util"

null_ls.register_formatter "stylua"

lspconfig.start_language_server("lua_ls", {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.tbl_extend("force", vim.split(package.path, ":"), {
          util.path("lua", "?.lua"),
          util.path("lua", "?", "init.lua"),
        }),
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        ignoreDir = { util.dir ".data" },
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})
