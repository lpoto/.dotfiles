--=============================================================================
--                     https://github.com/microsoft/vscode-json-languageservice
--[[===========================================================================

MasonInstall json-lsp

-----------------------------------------------------------------------------]]

return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
  init_options = {
    provideFormatter = true,
  },
}
