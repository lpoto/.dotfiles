--=============================================================================
--                                                            FTPLUGIN-MARKDOWN
--=============================================================================
if vim.g[vim.bo.filetype] then return end

vim.g[vim.bo.filetype] = function()
  return {
    language_server = "marksman",
    formatter = "prettier",
  }
end
