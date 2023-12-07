--=============================================================================
--                                                                  FTPLUGIN-GO
--=============================================================================
if vim.g[vim.bo.filetype] then return end

vim.g[vim.bo.filetype] = function()
  return {
    formatter = "goimports",
    language_server = "gopls",
  }
end
