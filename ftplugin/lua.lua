--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LUA
--=============================================================================
-- Loaded when a lua file is oppened.
--_____________________________________________________________________________

require("filetype")
  .new({
    copilot = true,
    formatter = function()
      return {
        exe = "stylua",
        args = {
          "--search-parent-directories",
          "--stdin-filepath",
          vim.api.nvim_buf_get_name(0),
          "--",
          "-",
        },
        stdin = true,
      }
    end,
    lsp_server = {
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
  })
  :load()
