--=============================================================================
--                 https://github.com/rcjsuen/dockerfile-language-server-nodejs
--[[===========================================================================

MasonInstall dockerfile-language-server

-----------------------------------------------------------------------------]]

return {
  cmd = { "docker-langserver", "--stdio" },
  filetypes = { "dockerfile" },
  workspace_required = false,
  root_markers = { "dockerfile", "Dockerfile", ".git" }
}
