--=============================================================================
-------------------------------------------------------------------------------
--                                                             INDENT-BLANKLINE
--=============================================================================
-- https://github.com/lukas-reineke/indent-blankline.nvim
--_____________________________________________________________________________

--[[
Indent guides for Neovim.

Provides vertical indentation lines for code.
--]]

require("plugin").new {
  "lukas-reineke/indent-blankline.nvim",
  as = "indent_blankline",
  event = "BufNewFile,BufReadPre",
  config = function()
    local indentline = require "indent_blankline"
    indentline.setup {
      --use │ for indentline
      char = "│",
      buftype_exclude = { "terminal" },
      show_current_context = true,
      --show_current_context_start = true,
      char_highlight_list = {
        "IndentBlanklineIndent",
      },
    }
  end,
}
