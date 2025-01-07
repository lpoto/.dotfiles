--=============================================================================
--                                                                  FTPLUGIN-C#
--=============================================================================
if vim.g[vim.bo.filetype] then return end

vim.g[vim.bo.filetype] = function()
  return {
    language_server = "csharp_ls",
    formatter = "csharpier",
  }
end
