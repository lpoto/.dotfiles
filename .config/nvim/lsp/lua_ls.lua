--=============================================================================
--                                 https://github.com/LuaLS/lua-language-server
--[[===========================================================================

MasonInstall lua-language-server

-----------------------------------------------------------------------------]]

return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".git",
    ".editorconfig",
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
  },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.tbl_extend("force", vim.split(package.path, ":"), {
          "lua/?.lua",
          "lua/?/init.lua",
        }),
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        ignoreDir = {
          ".storage/",
          ".git/",
          ".build/",
          "github-copilot/",
        },
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
