--=============================================================================
--                                                              FTPLUGIN-PYTHON
--=============================================================================
if vim.g[vim.bo.filetype] then return end

vim.g[vim.bo.filetype] = function()
  return {
    language_server = "pylsp",
  }
end
