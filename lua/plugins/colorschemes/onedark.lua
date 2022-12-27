--=============================================================================
-------------------------------------------------------------------------------
--                                                                 ONEDARK.NVIM
--=============================================================================
-- https://github.com/navarasu/onedark.nvim
--_____________________________________________________________________________

return {
  "navarasu/onedark.nvim",
  config = function()
    local onedark = require "onedark"

    onedark.setup {
      style = "darker",
      transparent = true,
      lualine = {
        transparent = true,
      },
    }

    vim.g.lualine_theme = "onedark"
  end,
}
