--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LUA
--[[===========================================================================
Loaded when a lua file is opened
-----------------------------------------------------------------------------]]
Util.ftplugin {
  formatter = "stylua",
  language_server = {
    "lua_ls",
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
          path = vim.tbl_extend("force", vim.split(package.path, ":"), {
            Util.path("lua", "?.lua"),
            Util.path("lua", "?", "init.lua"),
          }),
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          ignoreDir = {
            Util.dir ".storage",
            Util.dir ".git",
            Util.dir ".build",
            Util.dir "github-copilot",
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
