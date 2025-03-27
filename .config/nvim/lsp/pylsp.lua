--=============================================================================
--                              https://github.com/python-lsp/python-lsp-server
--[[===========================================================================

MasonInstall python-lsp-server

-----------------------------------------------------------------------------]]

return {
  cmd = { "pylsp" },
  filetypes = { "python" },
  single_file_support = true,
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git"
  }
}
