--=============================================================================
-------------------------------------------------------------------------------
--                                                                        OCAML
--=============================================================================

vim.g[vim.bo.filetype] = function()
  return {
    formatter = 'ocamlformat',
    language_server = 'ocamllsp'
  }
end
