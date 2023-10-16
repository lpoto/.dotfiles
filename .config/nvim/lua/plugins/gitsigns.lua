--=============================================================================
-------------------------------------------------------------------------------
--                                                                GITSIGNS.NVIM
--[[===========================================================================
https://github.com/lewis6991/gitsigns.nvim
https://github.com/willothy/flatten.nvim

Show git blames of current line, allow staging hunks and buffers...
Use flatten to open git commit files etc. in the same neovim session

keymaps:
# gitsigns
    - <leader>gd - Git diff
    - <leader>gs - Git stage buffer
    - <leader>gh - Git stage hunk
    - <leader>gu - Git unstage hunk
    - <leader>gr - Git reset buffer
# flatten
    - <leader>gc - Git commit
    - <leader>ga - Git commit amend
    - <leader>gp - Git pull
    - <leader>gP - Git push
    - <leader>gF - Git push force
    - <leader>gt - Git tag
    - <leader>gB - Git branch

-----------------------------------------------------------------------------]]

local shell = {}

local M = {
  'lewis6991/gitsigns.nvim',
  event = { 'BufRead', 'BufNewFile' },
  opts = {
    signcolumn = false,
    numhl = true,
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol',
      delay = 1000,
    },
    update_debounce = 250,
    on_attach = function(buf)
      local gitsigns = package.loaded.gitsigns
      local map = function(m, k, f) vim.keymap.set(m, k, f, { buffer = buf }) end
      map('n', '<leader>gd', gitsigns.diffthis)
      map('n', '<leader>gs', gitsigns.stage_buffer)
      map('n', '<leader>gh', gitsigns.stage_hunk)
      map('n', '<leader>gu', gitsigns.undo_stage_hunk)
      map('n', '<leader>gr', gitsigns.reset_buffer)
      if not vim.g.gitsigns_logged then
        vim.notify('Attached gitsigns', vim.log.levels.INFO)
        vim.g.gitsigns_logged = true
      end
    end,
  },
  dependencies = {
    {
      'willothy/flatten.nvim',
      event = 'VeryLazy',
      opts = {
        callbacks = {
          should_block = function() return true end,
          should_nest = function() return false end,
        },
        block_for = {},
        window = {
          diff = 'tab_vsplit',
          open = function(files, _, stdin_buf)
            local focus = files[1] or files[#files]
            if stdin_buf then focus = stdin_buf end
            local buf, win =
              shell.open_window(' ' .. (focus.fname or '') .. ' ')
            vim.api.nvim_set_current_buf(focus.bufnr)
            buf = focus.bufnr
            return buf, win
          end,
        },
      },
    },
  },
}

local run
function M.init()
  vim.keymap.set('n', '<leader>g', run '<INPUT> git')
  vim.keymap.set('n', '<leader>gc', run '<INPUT> git commit')
  vim.keymap.set('n', '<leader>ga', run '<INPUT> git commit --amend')
  vim.keymap.set(
    'n',
    '<leader>gp',
    run '<INPUT> git pull <GIT_REMOTE> <GIT_BRANCH>'
  )
  vim.keymap.set(
    'n',
    '<leader>gP',
    run '<INPUT> git push <GIT_REMOTE> <GIT_BRANCH>'
  )
  vim.keymap.set(
    'n',
    '<leader>gF',
    run '<INPUT> git push <GIT_REMOTE> <GIT_BRANCH> -f'
  )
  vim.keymap.set('n', '<leader>gf', run '<INPUT> git fetch')
  vim.keymap.set('n', '<leader>gt', run '<INPUT> git tag')
  vim.keymap.set('n', '<leader>gB', run '<INPUT> git branch')
end

function run(cmd)
  return function() return shell.run(cmd) end
end

local shell_augroup = 'AbstractShellAugroup'

---@param callback function(remote: string, branch: string)
---@param on_error nil|function(exit_code: number)
function shell.fetch_git_data(callback, on_error)
  on_error = on_error
    or function(_)
      vim.notify('Could not fetch git data', vim.log.levels.WARN)
    end
  local remote = ''
  vim.fn.jobstart('git remote show', {
    detach = false,
    on_stdout = function(_, data)
      for _, d in ipairs(data) do
        if d:len() > 0 then remote = d end
      end
    end,
    on_exit = function(_, remote_exit_code)
      if remote_exit_code ~= 0 then
        if type(on_error) == 'function' then return on_error() end
        return
      end
      local branch = ''
      vim.fn.jobstart('git branch --show-current', {
        detach = false,
        on_stdout = function(_, data)
          for _, d in ipairs(data) do
            if d:len() > 0 then branch = d end
          end
        end,
        on_exit = function(_, code)
          if code ~= 0 then
            if type(on_error) == 'function' then return on_error() end
            return
          end
          return callback(remote, branch)
        end,
      })
    end,
  })
end

---@param cmd string|table
function shell.process_command(cmd, cb)
  if type(cb) ~= 'function' then return end
  if type(cmd) == 'table' then
    local ok
    ok, cmd = pcall(table.concat, cmd, ' ')
    if not ok then return end
  elseif type(cmd) ~= 'string' then
    return
  end
  cmd = vim.trim(cmd)
  if cmd:len() == 0 then return end

  local callback = function(command)
    if type(command) ~= 'string' then return end
    local parts = vim.split(command, '<INPUT>')
    if #parts > 1 then
      local prefix = vim.trim(parts[1] or '')
      local suffix = vim.trim(parts[2] or '')
      suffix = vim.fn.input {
        prompt = '$' .. prefix .. ' ',
        default = suffix .. ' ',
        cancelreturn = false,
      }
      if type(suffix) ~= 'string' then return end
      command = prefix .. ' ' .. vim.trim(suffix)
    end
    return cb(command)
  end

  if cmd:find '<GIT_BRANCH>' or cmd:find '<GIT_REMOTE>' then
    return shell.fetch_git_data(function(remote, branch)
      cmd = cmd:gsub('<GIT_BRANCH>', branch)
      cmd = cmd:gsub('<GIT_REMOTE>', remote)
      return callback(cmd)
    end)
  end
  return callback(cmd)
end

local term_winid = nil
function shell.run(command, opts)
  shell.process_command(command, function(cmd)
    if type(opts) ~= 'table' then opts = {} end
    opts.cmd = cmd
    pcall(vim.api.nvim_clear_autocmds, {
      group = shell_augroup,
    })
    if
      type(term_winid) == 'number' and vim.api.nvim_win_is_valid(term_winid)
    then
      vim.fn.win_gotoid(term_winid)
      opts.buf = vim.api.nvim_get_current_buf()
      opts.win = vim.api.nvim_get_current_win()
      pcall(function()
        local config = vim.api.nvim_win_get_config(opts.win)
        config.title = ' ' .. opts.cmd .. ' '
        vim.api.nvim_win_set_config(opts.win, config)
      end)
      vim.bo.modified = false
    else
      opts.buf, opts.win = shell.open_window(' ' .. opts.cmd .. ' ')
      term_winid = opts.win
    end
    local term_opts = {
      detach = false,
      env = {
        VISUAL = 'nvim',
        EDITOR = 'nvim',
      },
      on_exit = function(...)
        if type(opts.on_exit) == 'function' then opts.on_exit(...) end
        if
          vim.api.nvim_get_current_win() == opts.win
          and vim.bo.buftype == 'terminal'
        then
          local delete = function()
            pcall(function()
              local buf = vim.api.nvim_get_current_buf()
              vim.api.nvim_win_close(opts.win, true)
              vim.api.nvim_buf_delete(buf, { force = true })
            end)
          end
          pcall(function()
            for _, k in ipairs { 'q', '<Esc>' } do
              vim.keymap.set(
                'n',
                k,
                delete,
                { buffer = vim.api.nvim_get_current_buf() }
              )
            end
            vim.api.nvim_create_autocmd('WinLeave', {
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
    if type(opts.on_stdout) == 'function' then
      term_opts.on_stdout = opts.on_stdout
    end
    if type(opts.on_stderr) == 'function' then
      term_opts.on_stderr = opts.on_stderr
    end
    vim.fn.termopen(opts.cmd, term_opts)
  end)
end

function shell.open_window(title)
  local buf = vim.api.nvim_create_buf(false, true)

  local win = vim.api.nvim_open_win(
    buf,
    true,
    vim.tbl_extend(
      'force',
      shell.get_centered_float_opts(vim.o.lines, vim.o.columns, 0.4),
      {
        relative = 'editor',
        style = 'minimal',
        border = 'rounded',
        title = title,
        title_pos = 'right',
      }
    )
  )
  return buf, win
end

function shell.get_centered_float_opts(lines, columns, scale)
  local pref_w = math.floor(columns * scale)
  local w = math.max(math.min(pref_w, columns), 100)
  local h = math.max(lines - 5, 12)

  local row = math.floor((lines - h) / 2)
  local col = (columns - w) / 2
  if columns % 2 ~= 0 then col = col - 1 end
  if w == columns then col = 0 end
  if h == lines then row = 0 end

  return {
    width = w,
    height = h,
    row = row,
    col = col,
  }
end

return M
