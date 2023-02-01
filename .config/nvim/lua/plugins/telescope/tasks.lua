--=============================================================================
-------------------------------------------------------------------------------
--                                                         TELESCOPE-TASKS-NVIM
--=============================================================================
-- https://github.com/lpoto/telescope-tasks.nvim
--_____________________________________________________________________________

--[[
Synchronous tasks from a telescope prompt.

Keymaps:
  - "<leader>a" - Open the tasks prompt
  - "<leader>e" - Toggle latest output
--]]

local M = {
  "lpoto/telescope-tasks.nvim",
}

M.keys = {
  {
    "<leader>a",
    function()
      require("telescope").extensions.tasks.tasks()
    end,
    mode = "n",
  },
  {
    "<leader>e",
    function()
      require("telescope").extensions.tasks.actions.toggle_last_output()
    end,
    mode = "n",
  },
}

function M.config()
  local telescope = require "telescope"
  telescope.setup {
    extensions = {
      tasks = {
        theme = "ivy",
        output = {
          style = "float",
          layout = "center",
        },
        --data_dir = false
      },
    },
  }

  telescope.load_extension "tasks"

  telescope.extensions.tasks.generators.default.all()
end

return M
