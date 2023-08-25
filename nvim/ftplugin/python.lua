--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PYTHON
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

vim.b.formatter = "black"
vim.b.language_server = {
  name = "pylsp",
  settings = {
    pylsp = {
      plugins = {
        autopep8 = { enabled = vim.g.pylsp_autopep8_enabled or false },
        flake8 = { enabled = vim.g.pylsp_flake8_enabled or false },
        pycodestyle = { enabled = vim.g.pylsp_pycodestyle_enabled or false },
        pyflakes = { enabled = vim.g.pylsp_pyflakes_enabled or false },
        mccabe = { enabled = vim.g.pylsp_mccabe_enabled or false },
        pylint = { enabled = vim.g.pylsp_pylint_enabled or false },
      },
    },
  },
}
