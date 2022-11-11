--=============================================================================
-------------------------------------------------------------------------------
--                                                             INDENT-BLANKLINE
--=============================================================================
-- https://github.com/lukas-reineke/indent-blankline.nvim
--_____________________________________________________________________________

local M = {}

---Default setup for the indent blankline plugin
---User '│' sign for indentline and show the current context.
require("indent_blankline").setup {
  --use │ for indentline
  char = "│",
  buftype_exclude = { "terminal" },
  show_current_context = true,
  --show_current_context_start = true,
  char_highlight_list = {
    "IndentBlanklineIndent",
  },
}
return M
