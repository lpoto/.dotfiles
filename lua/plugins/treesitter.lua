--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-TELESCOPE
--=============================================================================
-- https://github.com/nvim-treesitter/nvim-treesitter
--_____________________________________________________________________________

---Default setup for the treesitter
return require("nvim-treesitter.configs").setup {
  ensure_installed = "all",
  highlight = {
    disable = { "html" },
    enable = true,
    additional_vim_regex_highlighting = true,
  },
  indent = {
    enable = false,
  },
}
