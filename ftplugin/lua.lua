--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LUA
--=============================================================================
-- Loaded when a lua file is oppened.
--_____________________________________________________________________________

----------------------------------------------------------------------- OPTIONS
-- NOTE: set default tab width for lua

vim.opt.tabstop = 2 -- set the width of a tab to 2
vim.opt.softtabstop = 2 -- set the number of spaces that a tab counts for
vim.opt.shiftwidth = 2 -- number of spaces used for each step of indent

--------------------------------------------------------------------- LSPCONFIG
-- NOTE: set sumneko_lua the default lsp server for lua

--require("plugins.lspconfig").distinct_setup("lua", function()
--  -- 1. Install lua-language-server and add it to path
--  -- https://github.com/sumneko/lua-language-server
--  local runtime_path = vim.split(package.path, ";")
--  table.insert(runtime_path, "lua/?.lua")
--  table.insert(runtime_path, "lua/?/init.lua")
--  require("lspconfig").sumneko_lua.setup {
--    settings = {
--      Lua = {
--        runtime = {
--          version = "LuaJIT",
--          path = runtime_path,
--        },
--        diagnostics = {
--          globals = { "vim" },
--        },
--        workspace = {
--          library = vim.api.nvim_get_runtime_file("", true),
--          checkThirdParty = false,
--        },
--        telemetry = {
--          enable = false,
--        },
--      },
--    },
--    capabilities = require("plugins.cmp").default_capabilities(),
--  }
--  vim.fn.execute("LspStart", true)
--end)

--------------------------------------------------------------------- FORMATTER
-- NOTE: set stylua as the default formatter for lua

local plugin = require("plugin").get "formatter"

plugin:config(function(formatter)
  formatter.setup {
    filetype = {
      lua = {
        -- npm install -g lua-fmt
        function()
          local util = require "formatter.util"
          return {
            exe = "stylua",
            args = {
              "--search-parent-directories",
              "--stdin-filepath",
              util.escape_path(util.get_current_buffer_file_path()),
              "--",
              "-",
            },
            stdin = true,
          }
        end,
      },
    },
  }
end)

----------------------------------------------------------------------- COPILOT
-- NOTE: enable copilot for lua

--require("plugins.copilot").enable()
