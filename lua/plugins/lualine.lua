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
        component_separator = "",
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          "dashboard",
          "telescope_tasks_output",
          "noice",
          "SidebarNvim",
        },
      },
      winbar = {
        lualine_a = { "mode" },
        lualine_b = { "filename" },
        lualine_c = { "filetype", "diagnostics" },
        lualine_x = { "diff" },
        lualine_y = { "branch" },
        lualine_z = { "location" },
      },
      inactive_winbar = {
        lualine_a = {},
        lualine_b = { "filename" },
        lualine_c = {},
        lualine_x = { "filetype" },
        lualine_y = {},
        lualine_z = {},
      },
      sections = {},
      inactive_sections = {},
    }

    lualine.setup(setup)
    vim.opt.statusline = ""
  end,
}
