--=============================================================================
-------------------------------------------------------------------------------
--                                                                       RUST
--=============================================================================
if not vim.lsp.attach or vim.g['ftplugin_' .. vim.bo.filetype] then return end
vim.g['ftplugin_' .. vim.bo.filetype] = true

vim.lsp.attach {
  name = 'rust_analyzer',
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = 'clippy',
      },
    },
  },
}
