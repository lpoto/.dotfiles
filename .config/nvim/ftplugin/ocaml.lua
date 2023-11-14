--=============================================================================
--                                                               FTPLUGIN-OCAML
--=============================================================================
if vim.g[vim.bo.filetype] then return end

vim.g[vim.bo.filetype] = function()
  return {
    formatter = 'ocamlformat',
    language_server = 'ocamllsp'
  }
end
