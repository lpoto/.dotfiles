--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LUA
--=============================================================================
-- Loaded when a lua file is oppened.
--_____________________________________________________________________________

----------------------------------------------------------------------- OPTIONS
-- NOTE: set default tab width for lua

require("general.options").distinct_setup("lua", function()
  vim.opt.tabstop = 2 -- set the width of a tab to 2
  vim.opt.softtabstop = 2 -- set the number of spaces that a tab counts for
  vim.opt.shiftwidth = 2 -- number of spaces used for each step of indent
end)

--------------------------------------------------------------------- LSPCONFIG
-- NOTE: set sumneko_lua the default lsp server for lua

require("plugins.lspconfig").distinct_setup("lua", function()
  -- 1. Install lua-language-server and add it to path
  -- https://github.com/sumneko/lua-language-server
  require("lspconfig").sumneko_lua.setup {
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
          path = vim.split(
            table.concat({
              package.path,
              "lua/?.lua",
              "lua/?/init.lua",
            }, ";"),
            ";"
          ),
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        },
        telemetry = {
          enable = false,
        },
      },
    },
    capabilities = require("plugins.cmp").default_capabilities(),
    root_dir = require "util.root",
  }
  vim.fn.execute("LspStart", true)
end)

--------------------------------------------------------------------- FORMATTER
-- NOTE: set stylua as the default formatter for lua

require("plugins.formatter").distinct_setup("lua", {
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
})
