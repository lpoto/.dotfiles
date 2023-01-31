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
        icons_enabled = false,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          "dashboard",
          "telescope_tasks_output",
          "noice",
          "SidebarNvim",
          "NvimTree",
          "alpha",
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

    vim.api.nvim_create_augroup("StatuslineSeparator", {
      clear = true,
    })
    vim.opt.laststatus = 0
    vim.api.nvim_set_hl(0, "Statusline", { link = "Normal" })
    vim.api.nvim_set_hl(0, "StatuslineNC", { link = "Normal" })

    vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
      group = "StatuslineSeparator",
      callback = function()
        --local str = string.rep("─", vim.api.nvim_win_get_width(0))
        local str = string.rep("_", vim.api.nvim_win_get_width(0))
        vim.wo.statusline = "%#WinSeparator#" .. str
      end,
    })
  end,
}
