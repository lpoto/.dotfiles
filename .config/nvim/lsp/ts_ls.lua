--=============================================================================
--     https://github.com/typescript-language-server/typescript-language-server
--[[===========================================================================

MasonInstall typescript-language-server

-----------------------------------------------------------------------------]]

return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx"
  },
  init_options = {
    hostInfo = "neovim",
  },
}
