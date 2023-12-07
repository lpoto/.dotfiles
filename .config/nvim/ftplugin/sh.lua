--=============================================================================
--                                                                  FTPLUGIN-SH
--=============================================================================
if vim.g[vim.bo.filetype] then return end

vim.g[vim.bo.filetype] = function()
  return {
    formatter = "shfmt",
    language_server = "bashls",
  }
end
