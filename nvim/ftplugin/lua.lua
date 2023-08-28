--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LUA
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

Util.misc().lsp_attach("stylua")
Util.misc().lsp_attach({
  name = "lua_ls",
  root_patterns = { ".git" },
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
})
