--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LUA
--[[===========================================================================
Loaded when a lua file is opened
-----------------------------------------------------------------------------]]
local util = require "config.util"
util.ftplugin {
  formatter = "stylua",
  language_server = {
    "lua_ls",
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
          ignoreDir = {
            util.dir ".storage",
            util.dir ".git",
            util.dir ".build",
            util.dir "github-copilot",
          },
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  },
}
