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

return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufNewFile", "BufReadPre" },
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
      filetype_exclude = {
        "dashboard",
        "telescope_tasks_output",
        "noice",
        "SidebarNvim",
        "NvimTree",
        "alpha"
      },
    }
    vim.api.nvim_set_hl(0, "IndentBlanklineIndent", { fg = "#2b2a2a" })
    vim.api.nvim_set_hl(
      0,
      "IndentBlanklineContextChar",
      { fg = "#3b3939", bold = true }
    )
  end,
}
