--=============================================================================
-------------------------------------------------------------------------------
--                                                                 GRUVBOX.NVIM
--=============================================================================
-- https://github.com/ellisonleao/gruvbox.nvim
--_____________________________________________________________________________

local gruvbox = {}

---Default setup for the gruvbox plugin. This also takes
---care of all the additional higlight overrides and sets the
---gruvbox as the editor's colorscheme.
function gruvbox.setup()
  require("gruvbox").setup {
    undercurl = true,
    underline = true,
    bold = true,
    italic = true,
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true, -- invert background for search, diffs, statuslines and errors
    contrast = "hard", -- can be "hard", "soft" or empty string
    palette_overrides = {
      red = "#CD5C5C",
    },
    overrides = {
      Normal = { bg = nil, fg = "#ebdbb2" },
      Function = { fg = "#689d6a", bold = true, italic = true },
      Type = { fg = "#d1a858", bold = true, italic = true },
      Special = { fg = "#8ec07c", bold = false, italic = true },
      PreProc = { fg = "#b56060", bold = false, italic = true },
      Statement = { fg = "#CD5C5C", bold = true, italic = true },
      StorageClass = { fg = "#CD5C5C", bold = true, italic = true },
      Keyword = { fg = "#CD5C5C", bold = true, italic = true },
      Conditional = { fg = "#CD5C5C" },
      Label = { fg = "#CD5C5C" },
      Repeat = { fg = "#CD5C5C" },
      Exception = { fg = "#CD5C5C" },
      Constant = { fg = "#99A8A2" },
      Identifier = { fg = "#99A8A2" },
      Number = { fg = "#5097A4" },
      Float = { fg = "#5097A4" },
      CursorLine = { bg = "#292727", bold = true },
      --CursorColumn = {bg="#181818", bold=true},
      --ColorColumn = {bg="#1c1c1c", bold=true},
      IndentBlanklineIndent = { fg = "#2b2a2a" },
      IndentBlanklineContextChar = { fg = "#3b3939", bold = true },
    },
    dim_inactive = false,
    transparent_mode = true,
  }

  vim.cmd "colorscheme gruvbox"
end

return gruvbox
