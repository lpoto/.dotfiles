--=============================================================================
--                                                                 FTPLUGIN-TEX
--=============================================================================
if vim.g[vim.bo.filetype] then return end

vim.g[vim.bo.filetype] = function()
  return {
    formatter = "latexindent",
  }
end
