--=============================================================================
-------------------------------------------------------------------------------
--                                                                          PHP
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

vim.b.formatter = "phpcbf"
vim.b.language_server = {
  name = "phpactor",
  root_patterns = {
    ".git",
    "composer.json",
    "composer.lock",
    "vendor",
  },
}
