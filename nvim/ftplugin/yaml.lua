--=============================================================================
-------------------------------------------------------------------------------
--                                                                         YAML
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

Util.misc().lsp_attach("prettier")
Util.misc().lsp_attach({
  name = "yamlls",
  settings = {
    yaml = {
      keyOrdering = false,
    },
  },
})
