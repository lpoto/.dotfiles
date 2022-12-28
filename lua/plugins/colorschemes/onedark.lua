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
      style = "warmer",
      transparent = true,
      lualine = {
        transparent = true,
      },
      code_style = {
        comments = "italic",
        keywords = "italic",
        functions = "italic",
      },
      diagnostics = {
        darker = true,
        undercurl = true,
        background = false,
      },
    }

    vim.g.lualine_theme = "onedark"
  end,
}
