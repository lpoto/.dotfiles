--=============================================================================
-------------------------------------------------------------------------------
--                                                                     GITSIGNS
--=============================================================================
-- https://github.com/lewis6991/gitsigns.nvim
-- https://github.com/samjswill/nvim-unception
--[[___________________________________________________________________________

Git decorators.
Show the current line's git blame with a 700ms delay.

Keymaps:
   - <leader>gd: Open diff view
   - <leader>gs: Stage current buffer
   - <leader>gh: Stage hunk
   - <leader>gu: Unstage current buffer
   - <leader>gr: Reset current buffer

Add custom git commands:
   - <leader>gc: Git commit
   - <leader>gP: Git push
   - <leader>gp: Git pull
   - <leader>g or (:Git) :  Custom git command

------------------------------------------------------------------------------]]

local M = {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre" },
  dependencies = {
    "samjwill/nvim-unception",
    event = "VeryLazy",
  },
}

function M.init()
  vim.g.unception_block_while_host_edits = true
  vim.g.unception_enable_flavor_text = false

  vim.keymap.set("n", "<leader>g", M.git_command, {})
  vim.api.nvim_create_user_command("Git", function()
    M.git_command()
  end, {})
  vim.keymap.set("n", "<leader>gc", M.git_commit, {})
  vim.keymap.set("n", "<leader>gP", M.git_push, {})
  vim.keymap.set("n", "<leader>gp", M.git_pull, {})
end

function M.config()
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

local call_git_command

function M.git_command()
  call_git_command "git "
end

function M.git_push()
  call_git_command("git push ", "origin " .. (vim.g.gitsigns_head or ""))
end

function M.git_pull()
  call_git_command("git pull ", "origin " .. (vim.g.gitsigns_head or ""))
end

function M.git_commit()
  call_git_command "git commit "
end

local fetch_git_data
local run_cmd
function call_git_command(cmd, suffix)
  local no_git_data = function()
    vim.notify("No git data found", vim.log.levels.WARN, {
      title = "Git",
    })
  end

  local callback = function()
    suffix = vim.fn.input {
      prompt = cmd,
      default = suffix,
      cancelreturn = false,
    }
    if not suffix then
      return
    end
    cmd = cmd .. suffix
    run_cmd(cmd)
  end
  fetch_git_data(callback, no_git_data)
end

function run_cmd(cmd)
  if type(cmd) ~= "table" and type(cmd) ~= "string" then
    vim.notify("'cmd' should be a string or a table", vim.log.levels.WARN, {
      title = "Git Terminal",
    })
    return
  end
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

function fetch_git_data(callback, on_error)
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
