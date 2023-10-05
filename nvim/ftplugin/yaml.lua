--=============================================================================
-------------------------------------------------------------------------------
--                                                                         YAML
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

require("abstract.lsp"):attach("prettier")
require("abstract.lsp"):attach({
  name = "yamlls",
  settings = {
    yaml = {
      keyOrdering = false,
    },
  },
})
