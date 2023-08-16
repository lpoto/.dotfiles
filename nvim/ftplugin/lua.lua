--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LUA
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

vim.b.formatter = "stylua"
vim.b.language_server = {
  name = "lua_ls",
  root_patterns = { ".git" },
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
}
