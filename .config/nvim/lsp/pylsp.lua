--=============================================================================
--                              https://github.com/python-lsp/python-lsp-server
--[[===========================================================================

pip install "python-lsp-server[all]"
pip install python-lsp-isort
pip install python-lsp-black

or without any plugins:
  MasonInstall python-lsp-server

-----------------------------------------------------------------------------]]

return {
  cmd = { "pylsp" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git"
  },
  settings = {
    pylsp = {
      plugins = {
        -- formatter options
        black = { enabled = true },
        autopep8 = { enabled = false },
        yapf = { enabled = false },
        -- import sorting
        pyls_isort = { enabled = true },
        -- linter options
        pylint = { enabled = true },
        pyflakes = { enabled = false },
        pycodestyle = { enabled = false },
        mccabe = { enabled = false },
        -- type checker
        pylsp_mypy = { enabled = false },
        -- auto-completion options
        jedi_completion = { fuzzy = true },
      },
    },

  }
}
