--=============================================================================
-------------------------------------------------------------------------------
--                                                            GITHUB-NVIM-THEME
--[[===========================================================================
https://github.com/projekt0n/github-nvim-theme

-----------------------------------------------------------------------------]]
return {
  "projekt0n/github-nvim-theme",
  version = "v0.0.7",
  lazy = false,
  config = function()
    Util.require("github-theme", function(theme)
      theme.setup {
        theme_style = "dark",
        transparent = true,
        function_style = "italic",
        overrides = function()
          return {
            Identifier = { link = "Normal" },
            LineNr = { link = "WinSeparator" },
            ["@field"] = { link = "Special" },
            Type = { fg = "#E6BE8A" },
            ["@type"] = { link = "Type" },
            TabLine = { link = "WinSeparator" },
            TabLineFill = { link = "WinSeparator" },
            GitSignsAdd = { fg = "#569166" },
            GitSignsChange = { fg = "#658aba" },
            GitSignsDelete = { fg = "#a15c62" },
            StatusLine = { fg = "#9f9f9f", bg = "NONE" },
            Whitespace = { fg = "#292929", bg = "NONE" },
            NonText = { link = "Whitespace" },
            Folded = { bg = "NONE", fg = "#658aba" },
          }
        end,
      }
    end)
  end,
}
