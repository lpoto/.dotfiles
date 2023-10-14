--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PYTHON
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

vim.lsp.attach 'autopep8'
vim.lsp.attach 'pyright'
vim.lsp.attach 'flake8'
