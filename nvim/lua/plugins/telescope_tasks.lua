--=============================================================================
-------------------------------------------------------------------------------
--                                                         TELESCOPE-TASKS-NVIM
--[[===========================================================================
https://github.com/lpoto/telescope-tasks.nvim

Synchronous tasks from a telescope prompt.

Keymaps:
  - "<leader>a" - Open the tasks prompt
  - "<leader>e" - Toggle latest output
-----------------------------------------------------------------------------]]
local M = {
  "lpoto/telescope-tasks.nvim",
}

M.keys = {
  {
    "<leader>a",
    function()
      Util.require(
        "telescope",
        function(telescope) telescope.extensions.tasks.tasks() end
      )
    end,
    mode = "n",
  },
  {
    "<leader>e",
    function()
      Util.require(
        "telescope",
        function(telescope)
          telescope.extensions.tasks.actions.toggle_last_output()
        end
      )
    end,
    mode = "n",
  },
}

function M.config()
  Util.require("telescope", function(telescope)
    telescope.setup({
      extensions = {
        tasks = {
          output = {
            style = "float",
            layout = "center",
            scale = 0.6,
          },
          initial_mode = "normal",
          env = (vim.g.telescope_tasks or {}).env,
          binary = (vim.g.telescope_tasks or {}).binary,
        },
      },
    })

    telescope.load_extension("tasks")

    telescope.extensions.tasks.generators.default.all()
  end)
end

return M
