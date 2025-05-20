--=============================================================================
--                                  https://pkg.go.dev/golang.org/x/tools/gopls
--[[===========================================================================

MasonInstall gopls

-----------------------------------------------------------------------------]]

return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  workspace_required = false,
  organize_imports_before_format = true
}
