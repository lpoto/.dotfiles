--=============================================================================
-------------------------------------------------------------------------------
--                                                                   TYPESCRIPT
--=============================================================================
if not vim.lsp.attach or vim.g['ftplugin_' .. vim.bo.filetype] then return end
vim.g['ftplugin_' .. vim.bo.filetype] = true

vim.lsp.attach 'tsserver'
vim.lsp.attach 'prettier'
