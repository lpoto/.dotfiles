--=============================================================================
-------------------------------------------------------------------------------
--                                                                     GITSIGNS
--[[___________________________________________________________________________
https://github.com/TimUntersberger/neogit
-----------------------------------------------------------------------------]]
local M = {
  "lewis6991/gitsigns.nvim",
  event = { "User RealBufEnter" },
}

M.init = function()
  vim.keymap.set("n", "<leader>g", M.git_command)
  vim.keymap.set("n", "<leader>gg", M.git_status)
  vim.keymap.set("n", "<leader>gb", M.git_branch)
  vim.keymap.set("n", "<leader>gl", M.git_log)
  vim.keymap.set("n", "<leader>gS", M.git_stash)
  vim.keymap.set("n", "<leader>gc", M.git_commit)
  vim.keymap.set("n", "<leader>ga", M.git_commit_amend)
  vim.keymap.set("n", "<leader>gp", M.git_pull)
  vim.keymap.set("n", "<leader>gP", M.git_push)
end

function M.config()
  local gitsigns = require "gitsigns"

  gitsigns.setup {
    signcolumn = false,
    numhl = false,
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 700,
    },
    on_attach = function(bufnr)
      local gs = require "gitsigns"
      local opts = { buffer = bufnr }

      vim.keymap.set("n", "<leader>gd", gs.diffthis, opts)
      vim.keymap.set("n", "<leader>gs", gs.stage_buffer, opts)
      vim.keymap.set("n", "<leader>gh", gs.stage_hunk, opts)
      vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, opts)
      vim.keymap.set("n", "<leader>gr", gs.reset_buffer, opts)
    end,
  }
  vim.defer_fn(function()
    vim.api.nvim_exec_autocmds("User", {
      pattern = "GitsignsReady",
    })
  end, 100)
end

local default_telescope_options

function M.git_branch()
  local ok, _ = pcall(require, "telescope")
  if ok then
    require("telescope.builtin").git_branches(default_telescope_options())
  end
end

function M.git_log()
  local ok, _ = pcall(require, "telescope")
  if ok then
    require("telescope.builtin").git_commits(default_telescope_options())
  end
end

function M.git_stash()
  local ok, _ = pcall(require, "telescope")
  if ok then
    require("telescope.builtin").git_stash(default_telescope_options())
  end
end

local attach_git_status_mappings
function M.git_status()
  local ok, _ = pcall(require, "telescope")
  if ok then
    local opts = default_telescope_options()
    opts.attach_mappings = attach_git_status_mappings
    require("telescope.builtin").git_status(opts)
  end
end

local fetch_git_data

function M.git_command(suffix)
  suffix = suffix or ""
  fetch_git_data(function()
    require("plugins.unception").run_command_with_prompt("git ", suffix)
  end)
end

function M.git_commit()
  M.git_command "commit"
end

function M.git_commit_amend()
  M.git_command "commit --amend"
end

function M.git_push()
  fetch_git_data(function(remote, branch)
    require("plugins.unception").run_command_with_prompt(
      "git ",
      "push " .. remote .. " " .. branch
    )
  end)
end

function M.git_pull()
  fetch_git_data(function(remote, branch)
    require("plugins.unception").run_command_with_prompt(
      "git ",
      "pull " .. remote .. " " .. branch
    )
  end)
end

function default_telescope_options()
  local opts = require("telescope.themes").get_ivy()
  opts.selection_strategy = "row"
  opts.initial_mode = "normal"
  return opts
end

function attach_git_status_mappings(_, map)
  local actions = require "telescope.actions"
  actions.select_default:replace(actions.git_staging_toggle)
  map("n", "e", actions.file_edit)
  map("i", "<C-e>", actions.file_edit)
  map("i", "<Tab>", actions.move_selection_next)
  map("i", "<Tab>", actions.move_selection_next)
  map("n", "<Tab>", actions.move_selection_next)
  map("i", "<S-Tab>", actions.move_selection_previous)
  map("n", "<S-Tab>", actions.move_selection_previous)
  map("n", "s", actions.git_staging_toggle)
  map("i", "<C-s>", actions.git_staging_toggle)
  map("n", "<C-s>", actions.git_staging_toggle)
  return true
end

function fetch_git_data(callback, on_error)
  local log = require("config.util").logger "Fetch git data"
  on_error = on_error
    or function()
      log:warn "Could not fetch git data"
    end
  local remote = {}
  vim.fn.jobstart("git remote show", {
    detach = false,
    on_stdout = function(_, data)
      for _, d in ipairs(data) do
        if d:len() > 0 then
          table.insert(remote, d)
        end
      end
    end,
    on_exit = function(_, remote_exit_code)
      if remote_exit_code ~= 0 then
        return on_error(remote_exit_code)
      end
      local branch = {}
      vim.fn.jobstart("git branch --show-current", {
        detach = false,
        on_stdout = function(_, data)
          for _, d in ipairs(data) do
            if d:len() > 0 then
              table.insert(branch, d)
            end
          end
        end,
        on_exit = function(_, code)
          if code ~= 0 then
            return on_error(code)
          end
          return callback(
            table.concat(remote, " "),
            table.concat(branch, " ")
          )
        end,
      })
    end,
  })
end

return M
