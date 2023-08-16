--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PYTHON
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

vim.b.formatter = "black"
vim.b.linter = "flake8"
vim.b.language_server = "pylsp"
