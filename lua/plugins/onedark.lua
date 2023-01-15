--=============================================================================
-------------------------------------------------------------------------------
--                                                                 ONEDARK.NVIM
--=============================================================================
-- https://github.com/navarasu/onedark.nvim
--_____________________________________________________________________________

return {
  "navarasu/onedark.nvim",
  lazy = false,
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
      highlights = {
        FloatBorder = { bg = "#282C34" },
        NormalFloat = { bg = "#282C34" },
      },
    }

    vim.g.lualine_theme = "onedark"

    onedark.load()
  end,
}
