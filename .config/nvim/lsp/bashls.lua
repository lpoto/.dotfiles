--=============================================================================
--                             https://github.com/bash-lsp/bash-language-server
--[[===========================================================================

MasonInstall bash-language-server
MasonInstall shfmt
MasonInstall shellcheck

-----------------------------------------------------------------------------]]

return {
  cmd = { "bash-language-server", "start" },
  filetypes = { "bash", "sh", "zsh" },
  workspace_required = false,
  root_markers = { ".git" },
  settings = {
    bashIde = {
      globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.zsh|.command)",
    },
  },
}
