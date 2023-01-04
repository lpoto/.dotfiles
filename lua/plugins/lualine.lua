--=============================================================================
-------------------------------------------------------------------------------
--                                                                 LUALINE.NVIM
--=============================================================================
-- https://github.com/nvim-lualine/lualine.nvim
--_____________________________________________________________________________

--[[
A fast and configurable statusline plugin.
Displays both tabline and statusline.

Shows git branch, file encoding and tabs in tabline,
and other information in the statusline.
--]]

return {
  "nvim-lualine/lualine.nvim",
  event = { "BufNewFile", "BufReadPre" },
  config = function()
    local lualine = require "lualine"

    local setup = {
      options = {
        icons_enabled = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "filename" },
        lualine_c = { "filetype" },
        lualine_x = {},
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      tabline = {
        lualine_a = { "branch" },
        lualine_b = { "diff" },
        lualine_c = { "encoding" },
        lualine_x = {},
        lualine_y = {
          { "diagnostics", sources = { "nvim_diagnostic", "vim_lsp" } },
        },
        lualine_z = { { "tabs", mode = 2 } },
      },
    }
    setup.options.theme = vim.g.lualine_theme

    lualine.setup(setup)
  end,
}
