--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-UNCEPTION
--[[___________________________________________________________________________
https://github.com/samjwill/nvim-unception

Open files from neovim's terminal emulator without nesting sessions.

Add some convenient git commands, as now commit files may be opened in the
terminal emulator.

  - <leader>gc - git commit
  - <leader>ga - git commit --amend
  - <leader>gP - git push
  - <leader>gp - git pull
  - <leader>gf - git fetch
------------------------------------------------------------------------------]]
local M = {
  "samjwill/nvim-unception",
  event = "VeryLazy",
}

M.init = function()
  vim.g.unception_block_while_host_edits = true
  vim.g.unception_enable_flavor_text = false

  vim.keymap.set("n", "<leader>g", M.git_command)
  vim.keymap.set("n", "<leader>gc", M.git_commit)
  vim.keymap.set("n", "<leader>ga", M.git_commit_amend)
  vim.keymap.set("n", "<leader>gp", M.git_pull)
  vim.keymap.set("n", "<leader>gP", M.git_push)
  vim.keymap.set("n", "<leader>gf", M.git_fetch)
end

function M.config()
  vim.api.nvim_create_autocmd("User", {
    pattern = "UnceptionEditRequestReceived",
    once = false,
    callback = function()
      vim.schedule(function()
        pcall(function()
          -- NOTE: do not save buffers opened
          -- in the terminal emulator, scratch
          -- them immediately when they are
          -- closed.
          vim.bo.bufhidden = "wipe"
          vim.bo.swapfile = false
          vim.bo.buflisted = false
        end)
      end)
    end,
  })
end

function M.git_command(suffix)
  suffix = suffix or ""
  M.fetch_git_data(function()
    Util.require("plugins.unception", function(unception)
      unception.run_command_with_prompt("git ", suffix)
    end)
  end)
end

function M.git_commit()
  M.git_command "commit "
end

function M.git_commit_amend()
  M.git_command "commit --amend "
end

function M.git_push()
  M.fetch_git_data(function(remote, branch)
    Util.require("plugins.unception", function(unception)
      unception.run_command_with_prompt(
        "git ",
        "push " .. remote .. " " .. branch .. " "
      )
    end)
  end)
end

function M.git_fetch()
  M.git_command "fetch "
end

function M.git_pull()
  M.fetch_git_data(function(remote, branch)
    Util.require("plugins.unception", function(unception)
      unception.run_command_with_prompt(
        "git ",
        "pull " .. remote .. " " .. branch .. " "
      )
    end)
  end)
end

---@param cmd string
function M.run_command(cmd)
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
        vim.api.nvim_exec("keepjumps tabnew", false)
      else
        vim.api.nvim_buf_set_option(0, "modified", false)
      end
      vim.bo.bufhidden = "wipe"
      vim.bo.buflisted = false
      vim.fn.termopen(cmd, {
        detach = true,
        env = {
          VISUAL = "nvim",
          EDITOR = "nvim",
        },
      })
    end)
    if not ok and type(e) == "string" then
      Util.log():warn(e)
    end
  end)
end

function M.run_command_with_prompt(cmd, suffix)
  suffix = vim.fn.input {
    prompt = "$ " .. (cmd or ""),
    default = suffix,
    cancelreturn = false,
  }
  if type(suffix) ~= "string" then
    return
  end
  M.run_command(cmd .. " " .. suffix)
end

function M.fetch_git_data(callback, on_error)
  on_error = on_error
    or function()
      Util.log():warn "Could not fetch git data"
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
