--=============================================================================
-------------------------------------------------------------------------------
--                                                                         HTML
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

vim.lsp.attach 'html'
vim.lsp.attach 'htmx'
vim.lsp.attach 'prettier'
