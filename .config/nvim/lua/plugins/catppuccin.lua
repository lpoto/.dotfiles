--=============================================================================
-------------------------------------------------------------------------------
--                                                                   CATPPUCCIN
--=============================================================================
-- https://github.com/catppucin/nvim
--_____________________________________________________________________________

return {
  "catppuccin/nvim",
  event = "User LazyVimStarted",
  config = function()
    local catppuccin = require "catppuccin"
    catppuccin.setup {
      flavour = "frappe",
      transparent_background = true,
      dim_inactive = {
        enabled = false,
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        telescope = true,
        mini = true,
        noice = true,
      },
      no_italic = false,
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        functions = { "italic" },
      },
      color_overrides = {},
      custom_highlights = function()
        return {
          ["@method"] = { link = "@function", italic = true },
        }
      end,
    }
    vim.cmd.colorscheme "catppuccin"
  end,
}
