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
        theme = "ivy",
      },
    },
  }

  telescope.load_extension "tasks"

  M.add_task_generators(telescope)
end

function M.add_task_generators(telescope)
  telescope.extensions.tasks.generators.add(function(buf)
    local root = require "util.root"
    local path = require "util.path"
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
    local name = vim.api.nvim_buf_get_name(buf)

    -------------------------------------------------------------------- PYTHON
    if filetype == "python" then
      return {
        "Run current Python file",
        cmd = { "python", name },
      }
      -------------------------------------------------------------------- RUST
    elseif filetype == "rust" then
      if name:gmatch ".*/src/bin/[^/]+.rs" then
        return {
          "Run current Cargo binary",
          cmd = { "cargo", "run", "--bin", vim.fn.expand "%:p:t:r" },
          cwd = root { "cargo.toml", ".git" },
        }
      elseif name:gmatch ".*/src/.*.rs" then
        return {
          "Run current Cargo project",
          cmd = { "cargo", "run", "--bin", vim.fn.expand "%:p:t:r" },
          cwd = root { "cargo.toml", ".git" },
        }
      end
      ---------------------------------------------------------------------- GO
    elseif filetype == "go" then
      local r = root { "go.mod", ".git" }
      if vim.fn.filereadable(path.join(r, "go.mod")) == 1 then
        return {
          "Run current Go project",
          cmd = { "go", "run", "." },
          cwd = r,
        }
      else
        return {
          "Run current Go file",
          cmd = { "go", "run", name },
          cwd = r,
        }
      end
    end
  end)
end

return M
