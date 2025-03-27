--=============================================================================
--                 https://github.com/rcjsuen/dockerfile-language-server-nodejs
--[[===========================================================================

MasonInstall dockerfile-language-server

-----------------------------------------------------------------------------]]

return {
  cmd = { "docker-langserver", "--stdio" },
  filetypes = { "dockerfile" },
  single_file_support = true,
  root_markers = { "dockerfile", "Dockerfile", ".git" }
}
