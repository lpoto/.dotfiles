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

---@class Git
local Git = {}
---@class Shell
local Shell = {}

function M.config()
  vim.keymap.set("n", "<leader>gc", Git.commit)
  vim.keymap.set("n", "<leader>ga", Git.commit_amend)
  vim.keymap.set("n", "<leader>gp", Git.pull)
  vim.keymap.set("n", "<leader>gP", Git.push)
  vim.keymap.set("n", "<leader>gF", Git.push_force)
  vim.keymap.set("n", "<leader>gf", Git.fetch)
  vim.keymap.set("n", "<leader>gt", Git.tag)
  vim.keymap.set("n", "<leader>gB", Git.branch)
  vim.keymap.set("n", "<leader>gr", Git.restore)
  vim.keymap.set("n", "<leader>gs", Git.stage)
  vim.keymap.set("n", "<leader>gu", Git.unstage)

  vim.api.nvim_create_user_command("Git", function(opts)
    Git:default({
      suffix = opts.args,
      ask_for_input = opts.args:len() == 0,
    })
  end, {
    nargs = "*",
  })

  Util.require("flatten", function(flatten)
    flatten.setup({
      callbacks = {
        should_block = function()
          return true
        end,
        should_nest = function()
          return false
        end,
      },
      block_for = {},
      window = {
        diff = "tab_vsplit",
        open = function(files, _, stdin_buf)
          local focus = files[1] or files[#files]
          if stdin_buf then
            focus = stdin_buf
          end
          local buf, win = Shell:open_float(" " .. (focus.fname or "") .. " ")
          vim.api.nvim_set_current_buf(focus.bufnr)
          buf = focus.bufnr
          return buf, win
        end,
      },
    })
  end)
end

function Git:commit()
  Git:default("commit ")
end

function Git:commit_amend()
  Git:default("commit --amend ")
end

function Git:push()
  Shell:fetch_git_data(function(remote, branch)
    Git:default("push " .. remote .. " " .. branch .. " ")
  end)
end

function Git:push_force()
  Shell:fetch_git_data(function(remote, branch)
    Git:default("push " .. remote .. " " .. branch .. " --force ")
  end)
end

function Git:fetch()
  Git:default("fetch ")
end

function Git:branch()
  Git:default("branch ")
end

function Git:tag()
  Git:default("tag ")
end

function Git:restore()
  if vim.bo.modified then
    local ok, _ = pcall(vim.api.nvim_exec, "earlier 1f", false)
    if not ok then
      Util.log()
        :warn("File is modified, please save it first before restoring")
      return
    end
  end
  local custom_success_message = "Successfully restored current file"
  Git:default({
    suffix = "restore " .. vim.fn.expand("%:p") .. " ",
    ask_for_input = false,
    custom_success_message = custom_success_message,
    edit_after_end = true,
  })
end

function Git:stage()
  local custom_success_message = "Successfully staged current file"
  Git:default({
    suffix = "stage " .. vim.fn.expand("%:p") .. " ",
    ask_for_input = false,
    custom_success_message = custom_success_message,
  })
end

function Git:unstage()
  local custom_success_message = "Successfully unstaged current file"
  Git:default({
    suffix = "reset " .. vim.fn.expand("%:p") .. " ",
    ask_for_input = false,
    custom_success_message = custom_success_message,
  })
end

function Git:pull()
  Shell:fetch_git_data(function(remote, branch)
    Git:default({ suffix = "pull " .. remote .. " " .. branch .. " " })
  end)
end

function Git:default(opts)
  if type(opts) == "string" then
    opts = { suffix = opts }
  end
  if type(opts) ~= "table" then
    opts = {}
  end
  local cur_buf = vim.api.nvim_get_current_buf()

  local bufs = vim.api.nvim_list_bufs()

  if opts.ask_for_input == nil then
    opts.ask_for_input = true
  end
  if type(opts.suffix) ~= "string" then
    opts.suffix = ""
  end
  Shell:fetch_git_data(function()
    local o = {
      cmd = "git ",
      prompt = opts.ask_for_input,
      suffix = opts.suffix or "",
    }
    o.on_exit = function(_, code)
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
      if o.win ~= nil and vim.api.nvim_win_is_valid(o.win) then
        local cur_term = vim.api.nvim_win_get_buf(o.win)
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
        local do_delete = false
        if
          code == 0
          and type(opts.custom_success_message) == "string"
          and opts.custom_success_message:len() > 0
        then
          do_delete = true
          log(opts.custom_success_message)
        elseif #lines == 0 then
          if code == 0 then
            log(o.cmd, "SUCCESS")
          else
            log(o.cmd, "exited with code", code)
          end
          do_delete = true
        elseif opts.log_short_messages and #lines < 10 then
          log(table.concat(lines, "\n"))
          do_delete = true
        end
        if do_delete then
          vim.api.nvim_win_close(o.win, true)
          vim.api.nvim_buf_delete(cur_term, { force = true })
          o.win = nil
          o.buf = nil
        end
      end
      if
        vim.api.nvim_get_current_buf() == cur_buf and opts.edit_after_end
      then
        vim.api.nvim_exec("e", true)
      end
    end
    Shell:run_in_float(o)
  end)
end

local shell_augroup = "ShellAugroup"

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

local term_winid = nil
function Shell:run_in_float(opts)
  if type(opts) ~= "table" then
    opts = {}
  end
  if type(opts.cmd) ~= "string" then
    Util.log("Shell"):warn("The command should be a string")
    return
  end
  if opts.prompt then
    opts.suffix = vim.fn.input({
      prompt = "$ " .. (opts.cmd or ""),
      default = opts.suffix,
      cancelreturn = false,
      completion = "file",
    })
    if type(opts.suffix) ~= "string" then
      return
    end
  end
  if type(opts.suffix) == "string" then
    opts.cmd = opts.cmd:gsub("%s+$", "") .. " " .. opts.suffix
  end
  pcall(vim.api.nvim_clear_autocmds, {
    group = shell_augroup,
  })
  if
    type(term_winid) == "number" and vim.api.nvim_win_is_valid(term_winid)
  then
    vim.fn.win_gotoid(term_winid)
    opts.buf = vim.api.nvim_get_current_buf()
    opts.win = vim.api.nvim_get_current_win()
    pcall(function()
      local config = vim.api.nvim_win_get_config(opts.win)
      config.title = " " .. opts.cmd .. " "
      vim.api.nvim_win_set_config(opts.win, config)
    end)
    vim.bo.modified = false
  else
    opts.buf, opts.win = Shell:open_float(" " .. opts.cmd .. " ")
    term_winid = opts.win
  end
  local term_opts = {
    detach = false,
    env = {
      VISUAL = "nvim",
      EDITOR = "nvim",
    },
    on_exit = function(...)
      if type(opts.on_exit) == "function" then
        opts.on_exit(...)
      end
      if
        vim.api.nvim_get_current_win() == opts.win
        and vim.bo.buftype == "terminal"
      then
        local delete = function()
          pcall(function()
            local buf = vim.api.nvim_get_current_buf()
            vim.api.nvim_win_close(opts.win, true)
            vim.api.nvim_buf_delete(buf, { force = true })
          end)
        end
        pcall(function()
          for _, k in ipairs({ "q", "<Esc>" }) do
            vim.keymap.set(
              "n",
              k,
              delete,
              { buffer = vim.api.nvim_get_current_buf() }
            )
          end
          vim.api.nvim_create_autocmd("WinLeave", {
            group = vim.api.nvim_create_augroup(
              shell_augroup,
              { clear = true }
            ),
            buffer = vim.api.nvim_get_current_buf(),
            callback = delete,
          })
        end)
      end
    end,
  }
  if type(opts.on_stdout) == "function" then
    term_opts.on_stdout = opts.on_stdout
  end
  if type(opts.on_stderr) == "function" then
    term_opts.on_stderr = opts.on_stderr
  end
  vim.fn.termopen(opts.cmd, term_opts)
end

function Shell:open_float(title)
  local buf = vim.api.nvim_create_buf(false, true)

  local win = vim.api.nvim_open_win(
    buf,
    true,
    vim.tbl_extend(
      "force",
      Shell:get_centered_float_opts(vim.o.lines, vim.o.columns, 0.6),
      {
        relative = "editor",
        style = "minimal",
        border = "rounded",
        title = title,
        title_pos = "center",
      }
    )
  )
  return buf, win
end

function Shell:get_centered_float_opts(lines, columns, scale)
  local pref_w = math.floor(columns * scale)
  local w = math.max(math.min(pref_w, columns), 100)
  local h = math.max(lines - 5, 12)

  local row = 1
  local col = (columns - w) / 2
  if columns % 2 ~= 0 then
    col = col - 1
  end
  if w == columns then
    col = 0
  end
  if h == lines then
    row = 0
  end

  return {
    width = w,
    height = h,
    row = row,
    col = col,
  }
end

return M
