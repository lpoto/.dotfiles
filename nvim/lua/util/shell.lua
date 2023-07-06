local util = require("util")

---@class ShellUtil
local Shell = {}
---@param cmd string|table
function Shell:run_in_tab(cmd)
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
      util.log():warn(e)
    end
  end)
end

---@param cmd string|table
---@param suffix string
function Shell:run_in_tab_with_prompt(cmd, suffix)
  suffix = vim.fn.input({
    prompt = "$ " .. (cmd or ""),
    default = suffix,
    cancelreturn = false,
  })
  if type(suffix) ~= "string" then
    return
  end
  self:run_in_tab(cmd .. " " .. suffix)
end

---@param callback function(remote: string, branch: string)
---@param on_error nil|function(exit_code: number)
function Shell:fetch_git_data(callback, on_error)
  on_error = on_error
    or function(_)
      util.log():warn("Could not fetch git data")
    end
  local remote = ""
  vim.fn.jobstart("git remote show", {
    detach = false,
    on_stdout = function(_, data)
      for _, d in ipairs(data) do
        if d:len() > 0 then
          remote = d
        end
      end
    end,
    on_exit = function(_, remote_exit_code)
      if remote_exit_code ~= 0 then
        if type(on_error) == "function" then
          return on_error()
        end
        return
      end
      local branch = ""
      vim.fn.jobstart("git branch --show-current", {
        detach = false,
        on_stdout = function(_, data)
          for _, d in ipairs(data) do
            if d:len() > 0 then
              branch = d
            end
          end
        end,
        on_exit = function(_, code)
          if code ~= 0 then
            if type(on_error) == "function" then
              return on_error()
            end
            return
          end
          return callback(remote, branch)
        end,
      })
    end,
  })
end

return Shell
