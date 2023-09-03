--=============================================================================
-------------------------------------------------------------------------------
--                                                         TELESCOPE-TASKS.NVIM
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
    function() require("telescope").extensions.tasks.tasks() end,
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
  local ok, telescope = pcall(require, "telescope")
  if not ok then return end
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
end

return M
