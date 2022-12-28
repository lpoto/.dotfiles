--=============================================================================
-------------------------------------------------------------------------------
--                                                                  COLORSCHEME
--=============================================================================
-- load one of the colorschemes configured in lua/plugins/colorschemes/
--_____________________________________________________________________________
--NOTE: this is useful, as it allows  a different colorscheme to be loaded
-- for each project, by setting vim.g.colorscheme variable in a local config

if vim.fn.exists "g:colorscheme" == 0 then
  --vim.g.colorscheme = "gruvbox"
  --vim.g.colorscheme = "tokyonight"
  vim.g.colorscheme = "onedark"
end
vim.api.nvim_exec("colorscheme " .. vim.g.colorscheme, false)
