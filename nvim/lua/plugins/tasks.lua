--=============================================================================
-------------------------------------------------------------------------------
--                                                                   TASKS.NVIM
--[[===========================================================================
https://github.com/lpoto/tasks.nvim

Asynchronous tasks generator and manager for Neovim.

Keymaps:
  - "<leader>a" - Open the tasks selection
  - "<leader>e" - Toggle latest output
-----------------------------------------------------------------------------]]
local M = {
  dev = true,
  dir = "~/personal/tasks.nvim",
  opts = {
    command = "Tasks",
    generators = { "all" },
  },
  keys = {
    { "<leader>a", function() vim.cmd("Tasks") end, mode = "n" },
    {
      "<leader>e",
      function() vim.cmd("Tasks last_output toggle") end,
      mode = "n",
    },
  },
}

return M
