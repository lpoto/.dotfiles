--=============================================================================
--                                                                 FTPLUGIN-SQL
--=============================================================================
if vim.g[vim.bo.filetype] then return end

vim.g[vim.bo.filetype] = function()
  return {
    formatter = 'pg_format'
  }
end
