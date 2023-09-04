--=============================================================================
-------------------------------------------------------------------------------
--                                                                  COLORSCHEME
--[[===========================================================================
https://github.com/projekt0n/github-nvim-theme
-----------------------------------------------------------------------------]]

local M = {
  "projekt0n/github-nvim-theme",
  version = "v0.0.7",
  priority = 1000,
  lazy = false,
}

function M.config()
  local ok, theme = pcall(require, "github-theme")
  if not ok then return end
  ---@diagnostic disable-next-line
  theme.setup({
    theme_style = "dark",
    transparent = true,
    function_style = "italic",
    overrides = function()
      return {
        Identifier = { link = "Normal" },
        LineNr = { link = "WinSeparator" },
        ["@method"] = { link = "@function" },
        ["@function.builtin"] = { link = "@function" },
        ["@constructor"] = { link = "@function" },
        Type = { fg = "#E6BE8A" },
        ["@type"] = { link = "Type" },
        StatusLine = { link = "WinSeparator" },
        StatusLineNC = { link = "StatusLine" },
        TabLine = { fg = "#7f98a3", bg = "NONE", style = "italic" },
        TabLineSel = { link = "Special" },
        TabLineFill = { link = "WinSeparator" },
        Whitespace = { fg = "#292929", bg = "NONE" },
        NonText = { link = "Whitespace" },
        Folded = { bg = "NONE", fg = "#658ABA" },
        NormalFloat = { bg = "NONE" },
        FloatBorder = { link = "WinSeparator" },
        ["@label.json"] = { link = "@field.yaml" },

        TelescopeBorder = { link = "WinSeparator" },
        TelescopeTitle = { link = "TabLineSel" },

        GitSignsAdd = { fg = "#569166" },
        GitSignsChange = { fg = "#658AbA" },
        GitSignsDelete = { fg = "#A15C62" },
      }
    end,
  })
  vim.api.nvim_set_hl(
    0,
    "@function.builtin",
    { fg = "#a398f5", italic = true }
  )
end

return M
