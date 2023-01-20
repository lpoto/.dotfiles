--=============================================================================
-------------------------------------------------------------------------------
--                                                                 ONEDARK.NVIM
--=============================================================================
-- https://github.com/navarasu/onedark.nvim
--_____________________________________________________________________________

local colors = {
  darker_black = "#1b1f27",
  black = "#1e222a", --  nvim bg
  black2 = "#252931",
  grey = "#42464e",
  light_grey = "#6f737b",
  red = "#e06c75",
  green = "#98c379",
}

return {
  "navarasu/onedark.nvim",
  lazy = false,
  priority = 3,
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
        FloatBorder = {
          fg = colors.darker_black,
          bg = "None",
        },
        NormalFloat = {
          bg = "#282C34",
        },
        TelescopeBorder = {
          fg = colors.darker_black,
        },
        TelescopePromptBorder = {
          fg = colors.grey,
        },
        TelescopePreviewBorder = {
          fg = colors.grey,
        },
        TelescopePreviewTitle = {
          fg = colors.black,
          bg = colors.light_grey,
        },
        TelescopePromptTitle = {
          fg = colors.black,
          bg = colors.red,
        },
        TelescopeResultsTitle = {
          fg = colors.black,
          bg = colors.light_grey,
        },
      },
    }

    vim.g.lualine_theme = "onedark"

    onedark.load()
  end,
}
