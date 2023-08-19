--=============================================================================
-------------------------------------------------------------------------------
--                                                                ZEN_MODE.NVIM
--[[===========================================================================
https://github.com/folke/zen-mode.nvim

Focus the current window and remove all disctractions

Keymaps:
  - "<leader>z"  - toggle zen mode
-----------------------------------------------------------------------------]]
local M = {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  keys = {
    {
      "<leader>z",
      function() vim.api.nvim_exec("ZenMode", false) end,
      mode = "n",
    },
  },
  opts = {
    window = {
      width = 160,
    },
    on_open = function(win)
      pcall(function()
        local config = vim.api.nvim_win_get_config(win)
        local buf = vim.api.nvim_win_get_buf(win)
        local filename = vim.api.nvim_buf_get_name(buf)
        if filename:len() == 0 then return end
        filename = vim.fn.fnamemodify(filename, ":~:.")
        config.title = filename
        config.title_pos = "center"
        config.border = { " " }
        vim.api.nvim_win_set_config(win, config)
      end)
    end,
  },
}

return M
