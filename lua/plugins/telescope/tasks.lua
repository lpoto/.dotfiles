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
  dev = true,
  dir = "/home/luka/personal/telescope-tasks.nvim",
}

function M.init()
  vim.keymap.set("n", "<leader>a", function()
    require("telescope").extensions.tasks.tasks()
  end)
  vim.keymap.set("n", "<leader>e", function()
    require("telescope").extensions.tasks.actions.toggle_last_output()
  end)
end

function M.config()
  local telescope = require "telescope"
  telescope.setup {
    extensions = {
      tasks = {
        theme = "dropdown",
      },
    },
  }

  telescope.load_extension "tasks"

  telescope.extensions.tasks.generators.enable_default()

  M.add_task_generators(telescope)
end

function M.add_task_generators(telescope)
  local tasks = telescope.extensions.tasks
  local util = tasks.util

  tasks.generators.add_batch {
    ---------------------------------------------------------------------- RUST
    {
      generator = function()
        return {
          "Run current Cargo binary",
          cwd = util.find_current_file_root { "Cargo.toml" },
          cmd = { "cargo", "run", "--bin", vim.fn.expand "%:p:t:r" },
        }
      end,
      opts = {
        filetypes = { "rust" },
        patterns = { ".*/src/bin/[^/]+.rs" },
        parent_dir_includes = { "Cargo.toml" },
      },
    },
    {
      generator = function()
        return {
          "Run current Cargo project",
          cwd = util.find_current_file_root { "Cargo.toml" },
          cmd = { "cargo", "run" },
        }
      end,
      opts = {
        parent_dir_includes = { "Cargo.toml" },
        ignore_patterns = { ".*/src/bin/[^/]+.rs" },
        filetypes = { "rust" },
      },
    },
    -------------------------------------------------------------------- PYTHON
    {
      generator = function(buf)
        return {
          "Run current Python file",
          cmd = { "python", vim.api.nvim_buf_get_name(buf) },
        }
      end,
      opts = {
        filetypes = { "python" },
      },
    },
    ------------------------------------------------------------------------ GO
    {
      generator = function(buf)
        return {
          "Run current Go file",
          cmd = { "go", "run", vim.api.nvim_buf_get_name(buf) },
          cwd = util.find_current_file_root { "go.mod" },
        }
      end,
      opts = {
        filetypes = { "go" },
      },
    },
    {
      generator = function()
        return {
          "Run Go project",
          cmd = { "go", "run", "." },
          cwd = util.find_current_file_root { "go.mod" },
        }
      end,
      opts = {
        filetypes = { "go" },
        parent_dir_includes = { "go.mod" },
      },
    },
  }
end

return M
