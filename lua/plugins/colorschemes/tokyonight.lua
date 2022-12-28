--=============================================================================
-------------------------------------------------------------------------------
--                                                              TOKYONIGHT.NVIM
--=============================================================================
-- https://github.com/folke/tokyonight.nvim
--_____________________________________________________________________________

return {
  "folke/tokyonight.nvim",
  dir = vim.fn.stdpath "data" .. "/lazy/tokyonight.nvim",
  config = function()
    local tokyonight = require "tokyonight"

    tokyonight.setup {
      style = "moon",
      transparent = true,
      styles = {
        comments = { italic = true },
        functions = { italic = true },
        keywords = { italic = true },
        floats = "transparent",
        sidebars = "transparent",
      },
      hide_inactive_statusline = true,
      dim_inactive = true,
      on_highlights = function(hl)
        hl.TelescopeNormal = {
          bg = nil,
        }
        hl.TelescopeBorder = {
          bg = nil,
        }
      end,
    }

    vim.g.lualine_theme = "tokyonight"
  end,
}
