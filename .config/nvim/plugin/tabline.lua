--=============================================================================
--                                                                      TABLINE
--[[===========================================================================
--
-- Simplistic tabline that is always visible, shows all relevant
-- information and acts as statusline replacement.
--
-----------------------------------------------------------------------------]]

vim.pack.add {
  {
    src = "https://github.com/lpoto/tabline.nvim",
    version = "v0.0.1"
  }
}

require "tabline".setup { sidebar = true }
