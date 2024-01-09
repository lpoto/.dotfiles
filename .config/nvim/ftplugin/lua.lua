--=============================================================================
--                                                                 FTPLUGIN-LUA
--=============================================================================
if vim.g[vim.bo.filetype] then return end

vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.g[vim.bo.filetype] = function()
  return {
    formatter = "stylua",
    language_server = {
      name = "lua_ls",
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
      root_dir = function()
        return vim.fs.find({ ".git", ".editorconfig" }, {})[0]
          or vim.fn.getcwd()
      end,
    },
  }
end
