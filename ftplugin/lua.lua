--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LUA
--=============================================================================
-- Loaded when a lua file is opened.
-- Install required servers, linters and formatters with:
--
--                        :MasonInstall <pkg>   (or :Mason)
--
-- To see available linters and formatters for current filetype, run:
--
--                        :NullLsInfo
--
-- To see attached language server for current filetype, run:
--
--                        :LspInfo
--_____________________________________________________________________________

local filetype = require "filetype"

filetype.config {
  filetype = "lua",
  priority = 1,
  copilot = true,
  formatter = "stylua",
  language_server = {
    "sumneko_lua",
    {
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            path = vim.tbl_extend("force", vim.split(package.path, ";"), {
              "lua/?.lua",
              "lua/?/init.lua",
            }),
          },
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    },
  },
}

filetype.load "lua"
