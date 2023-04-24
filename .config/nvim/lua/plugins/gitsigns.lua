--=============================================================================
-------------------------------------------------------------------------------
--                                                                     GITSIGNS
--[[___________________________________________________________________________
https://github.com/TimUntersberger/neogit
-----------------------------------------------------------------------------]]
local M = {
  "lewis6991/gitsigns.nvim",
  event = { "User RealBufEnter" },
  dependencies = {
    "samjwill/nvim-unception",
  },
}

M.init = function()
  vim.keymap.set("n", "<leader>g", M.git_command)
  vim.keymap.set("n", "<leader>gg", M.git_status)
  vim.keymap.set("n", "<leader>gb", M.git_branch)
  vim.keymap.set("n", "<leader>gl", M.git_log)
  vim.keymap.set("n", "<leader>gS", M.git_stash)
  vim.keymap.set("n", "<leader>gc", M.git_commit)
  vim.keymap.set("n", "<leader>gp", M.git_pull)
  vim.keymap.set("n", "<leader>gP", M.git_push)

  vim.g.unception_block_while_host_edits = true
  vim.g.unception_enable_flavor_text = false
end

function M.config()
  M.unception_config()

  local gitsigns = require "gitsigns"

  gitsigns.setup {
    signcolumn = false,
    numhl = true,
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
end

function M.unception_config()
  vim.api.nvim_create_autocmd("User", {
    pattern = "UnceptionEditRequestReceived",
    callback = function()
      vim.schedule(function()
        if vim.bo.buftype ~= "" or vim.bo.filetype:match "^git" then
          vim.bo.bufhidden = "wipe"
          vim.bo.swapfile = false
        end
      end)
    end,
  })
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
local run_command
local run_command_with_prompt

function M.git_command(suffix)
  suffix = suffix or ""
  fetch_git_data(function()
    run_command_with_prompt("git ", suffix)
  end)
end

function M.git_commit()
  M.git_command "commit"
end

function M.git_push()
  fetch_git_data(function(remote, branch)
    run_command_with_prompt("git ", "push " .. remote .. " " .. branch)
  end)
end

function M.git_pull()
  fetch_git_data(function(remote, branch)
    run_command_with_prompt("git ", "pull " .. remote .. " " .. branch)
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
  on_error = on_error
    or function()
      vim.schedule(function()
        vim.notify("Could not fetch git data", vim.log.levels.WARN, {
          "Git",
        })
      end)
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

---@param cmd string
function run_command(cmd)
  local f = function()
    local new_tab = true
    if vim.b.terminal_job_id then
      local r = vim.fn.jobwait({ vim.b.terminal_job_id }, 0)
      local _, n = next(r)
      if n == -3 then
        new_tab = false
      end
    end
    vim.schedule(function()
      local ok, e = pcall(function()
        if new_tab then
          vim.api.nvim_exec("tabnew", false)
        else
          vim.api.nvim_buf_set_option(0, "modified", false)
        end
        vim.fn.termopen(cmd, {
          detach = false,
          env = {
            VISUAL = "nvim",
            EDITOR = "nvim",
          },
        })
      end)
      if not ok and type(e) == "string" then
        vim.notify(e, vim.log.levels.WARN, {
          title = "Git Terminal",
        })
      end
    end)
  end
  if not package.loaded["gitsigns"] then
    M.config()
    vim.defer_fn(f, 100)
  else
    f()
  end
end

function run_command_with_prompt(cmd, suffix)
  suffix = vim.fn.input {
    prompt = cmd,
    default = suffix,
    cancelreturn = false,
  }
  if type(suffix) ~= "string" then
    return
  end
  run_command(cmd .. " " .. suffix)
end

return M
