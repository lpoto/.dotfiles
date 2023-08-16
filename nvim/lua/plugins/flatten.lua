--=============================================================================
-------------------------------------------------------------------------------
--                                                                 FLATTEN.NVIM
--[[___________________________________________________________________________
https://github.com/willothy/flatten.nvim

Allow opening files from terminal in the same nvim session.

Add some convenient git commands, as now commit files may be opened in the
same session now.

  - <leader>gc - git commit
  - <leader>ga - git commit --amend
  - <leader>gP - git push
  - <leader>gF - git push --force
  - <leader>gp - git pull
  - <leader>gf - git fetch
  - <leader>gB - git branch
  - <leader>gr - git reset current file
  - <leader>gs - git stage current file
  - <leader>gu - git unstage current file
------------------------------------------------------------------------------]]
local M = {
  "willothy/flatten.nvim",
  lazy = false,
}

local git_commands = {}

function M.config()
  vim.keymap.set("n", "<leader>g", git_commands.default)
  vim.keymap.set("n", "<leader>gc", git_commands.commit)
  vim.keymap.set("n", "<leader>ga", git_commands.commit_amend)
  vim.keymap.set("n", "<leader>gp", git_commands.pull)
  vim.keymap.set("n", "<leader>gP", git_commands.push)
  vim.keymap.set("n", "<leader>gF", git_commands.push_force)
  vim.keymap.set("n", "<leader>gf", git_commands.fetch)
  vim.keymap.set("n", "<leader>gt", git_commands.tag)
  vim.keymap.set("n", "<leader>gB", git_commands.branch)
  vim.keymap.set("n", "<leader>gr", git_commands.restore)
  vim.keymap.set("n", "<leader>gs", git_commands.stage)
  vim.keymap.set("n", "<leader>gu", git_commands.unstage)

  Util.require("flatten", function(flatten)
    flatten.setup({
      callbacks = {
        should_block = function()
          return false
        end,
        should_nest = function()
          return false
        end,
      },
      block_for = {},
      window = {
        open = "tab",
        diff = "tab_vsplit",
      },
    })
  end)
end

---@class ShellUtil
local Shell = {}

function git_commands.commit()
  git_commands.default("commit ")
end

function git_commands.commit_amend()
  git_commands.default("commit --amend ")
end

function git_commands.push()
  Shell:fetch_git_data(function(remote, branch)
    git_commands.default("push " .. remote .. " " .. branch .. " ")
  end)
end

function git_commands.push_force()
  Shell:fetch_git_data(function(remote, branch)
    git_commands.default("push " .. remote .. " " .. branch .. " --force ")
  end)
end

function git_commands.fetch()
  git_commands.default("fetch ")
end

function git_commands.branch()
  git_commands.default("branch ")
end

function git_commands.tag()
  git_commands.default("tag ")
end

function git_commands.restore()
  if vim.bo.modified then
    local ok, _ = pcall(vim.api.nvim_exec, "earlier 1f", false)
    if not ok then
      Util.log()
        :warn("File is modified, please save it first before restoring")
      return
    end
  end
  local custom_success_message = "Successfully restored current file"
  git_commands.default(
    "restore " .. vim.fn.expand("%:p") .. " ",
    false,
    custom_success_message,
    true
  )
end

function git_commands.stage()
  local custom_success_message = "Successfully staged current file"
  git_commands.default(
    "stage " .. vim.fn.expand("%:p") .. " ",
    false,
    custom_success_message
  )
end

function git_commands.unstage()
  local custom_success_message = "Successfully unstaged current file"
  git_commands.default(
    "reset " .. vim.fn.expand("%:p") .. " ",
    false,
    custom_success_message
  )
end

function git_commands.pull()
  Shell:fetch_git_data(function(remote, branch)
    git_commands.default("pull " .. remote .. " " .. branch .. " ")
  end)
end

function git_commands.default(
  suffix,
  ask_for_input,
  custom_success_message,
  edit_after_end
)
  local cur_buf = vim.api.nvim_get_current_buf()

  local cur_term_win = nil
  local bufs = vim.api.nvim_list_bufs()

  if ask_for_input == nil then
    ask_for_input = true
  end
  suffix = suffix or ""
  Shell:fetch_git_data(function()
    if ask_for_input then
      suffix = vim.fn.input({
        prompt = "git ",
        default = suffix,
        cancelreturn = "",
      })
      if suffix == "" then
        return
      end
    end
    local cmd = "git " .. suffix
    vim.api.nvim_exec("noautocmd keepjumps tabnew", false)
    cur_term_win = vim.api.nvim_get_current_win()
    vim.fn.termopen(cmd, {
      detach = false,
      on_exit = function(_, code)
        vim.schedule(function()
          pcall(function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if
                vim.api.nvim_buf_get_name(buf) == ""
                and vim.api.nvim_buf_get_option(buf, "filetype") == ""
                and vim.api.nvim_buf_get_option(buf, "buftype") == ""
                and not vim.tbl_contains(bufs, buf)
              then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
              end
            end
          end)
        end)
        if
          cur_term_win ~= nil and vim.api.nvim_win_is_valid(cur_term_win)
        then
          local cur_term = vim.api.nvim_win_get_buf(cur_term_win)
          local lines = vim.tbl_filter(function(el)
            return #el > 0
          end, vim.api.nvim_buf_get_lines(cur_term, 0, -1, false))
          local log = function(...)
            local log_name = "Git"
            if code == 0 then
              Util.log({ delay = 50, title = log_name }):info(...)
            else
              Util.log({ delay = 50, title = log_name }):warn(...)
            end
          end
          if
            code == 0
            and type(custom_success_message) == "string"
            and custom_success_message:len() > 0
          then
            log(custom_success_message)
          elseif #lines == 0 then
            if code == 0 then
              log(cmd, "SUCCESS")
            else
              log(cmd, "exited with code", code)
            end
          elseif #lines < 10 and #vim.api.nvim_list_tabpages() > 1 then
            log(table.concat(lines, "\n"))
          end
          vim.api.nvim_win_close(cur_term_win, true)
          vim.api.nvim_buf_delete(cur_term, { force = true })
        end
        cur_term_win = nil
        if vim.api.nvim_get_current_buf() == cur_buf and edit_after_end then
          vim.api.nvim_exec("e", true)
        end
      end,
    })
  end)
end

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
      Util.log():warn(e)
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
      Util.log():warn("Could not fetch git data")
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

return M
