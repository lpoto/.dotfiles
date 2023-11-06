--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LUA
--=============================================================================
if not vim.lsp.attach or vim.g['ftplugin_' .. vim.bo.filetype] then return end
vim.g['ftplugin_' .. vim.bo.filetype] = true

vim.lsp.attach {
  name = 'lua_ls',
  root_dir = function()
    return vim.fs.find({ '.git', '.editorconfig' }, {})[0] or vim.fn.getcwd()
  end,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = vim.tbl_extend('force', vim.split(package.path, ':'), {
          'lua/?.lua',
          'lua/?/init.lua',
        }),
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        ignoreDir = {
          '.storage/',
          '.git/',
          '.build/',
          'github-copilot/',
        },
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
