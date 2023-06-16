--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LUA
--[[===========================================================================
Loaded when a lua file is opened
-----------------------------------------------------------------------------]]
Util.ftplugin()
  :new()
  :attach_formatter("stylua")
  :attach_language_server("lua_ls", {
    root_dir = Util.misc().root_fn(),
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
          path = vim.tbl_extend("force", vim.split(package.path, ":"), {
            Util.path():new("lua", "?.lua"),
            Util.path():new("lua", "?", "init.lua"),
          }),
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          ignoreDir = {
            Util.path():dir(".storage"),
            Util.path():dir(".git"),
            Util.path():dir(".build"),
            Util.path():dir("github-copilot"),
          },
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })
