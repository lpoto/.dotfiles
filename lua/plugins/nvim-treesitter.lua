--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-TELESCOPE
--=============================================================================
-- https://github.com/nvim-treesitter/nvim-treesitter
--_____________________________________________________________________________

local treesitter = require("util.packer.wrapper").get "nvim-treesitter"

---Default setup for the treesitter
treesitter:config(function()
  require("nvim-treesitter.configs").setup {
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
end)
