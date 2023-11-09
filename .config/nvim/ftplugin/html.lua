--=============================================================================
-------------------------------------------------------------------------------
--                                                                         HTML
--=============================================================================
if not vim.lsp.attach or vim.g['ftplugin_' .. vim.bo.filetype] then return end
vim.g['ftplugin_' .. vim.bo.filetype] = true

vim.lsp.attach {
  name = 'html',
  on_attach = function(c)
    c.server_capabilities.documentFormattingProvider = false
  end
}
vim.lsp.attach 'prettier'
