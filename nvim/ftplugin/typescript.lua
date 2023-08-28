--=============================================================================
-------------------------------------------------------------------------------
--                                                                   TYPESCRIPT
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

vim.b.language_server = "tsserver"
vim.b.formatter = "prettier"
