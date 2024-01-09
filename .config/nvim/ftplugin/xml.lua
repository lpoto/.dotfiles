--=============================================================================
--                                                                 FTPLUGIN-XML
--=============================================================================
if vim.g[vim.bo.filetype] then return end

vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.g[vim.bo.filetype] = function()
  return {
    language_server = "lemminx",
  }
end
