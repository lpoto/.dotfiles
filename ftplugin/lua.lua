--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LUA
--=============================================================================
-- Loaded when a lua file is oppened.
--_____________________________________________________________________________

require("filetype")
  .new({
    always = function()
      vim.bo.tabstop = 2
      vim.bo.softtabstop = 2
      vim.bo.shiftwidth = 2
    end,
    copilot = true,
    formatter = function()
      return {
        exe = "stylua",
        args = {
          "--search-parent-directories",
          "--stdin-filepath",
          vim.fn.expand "%:p",
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
