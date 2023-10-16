--=============================================================================
-------------------------------------------------------------------------------
--                                                                USER COMMANDS
--=============================================================================

------- Add custom commands for writing and quitting, so there is no annoyance
-------- when misstyping
for _, key in ipairs { 'W', 'Wq', 'WQ', 'WqA', 'Wqa', 'WQa', 'WQA' } do
  vim.api.nvim_create_user_command(key, key:lower(), {
    bang = true,
    bar = true,
    complete = 'file',
    nargs = '*',
  })
end
for _, key in ipairs { 'Q', 'Qa', 'QA' } do
  vim.api.nvim_create_user_command(key, key:lower(), {
    bang = true,
    bar = true,
  })
end

------------------------------------------------ Toggle quickfix with :Quickfix
vim.api.nvim_create_user_command('Quickfix', function(opts)
  local enter = vim.tbl_contains(opts.fargs or {}, 'enter')
  local open_only = vim.tbl_contains(opts.fargs or {}, 'owpen')
  if
    #vim.tbl_filter(
      function(winid)
        return vim.api.nvim_buf_get_option(
          vim.api.nvim_win_get_buf(winid),
          'buftype'
        ) == 'quickfix'
      end,
      vim.api.nvim_list_wins()
    ) > 0
  then
    if open_only ~= true then vim.api.nvim_exec2('cclose', {}) end
  else
    local winid = vim.api.nvim_get_current_win()
    vim.api.nvim_exec2('noautocmd keepjumps copen', {})
    if
      #vim.tbl_filter(
        function(l) return #l > 0 end,
        vim.api.nvim_buf_get_lines(0, 0, -1, false)
      ) == 0
    then
      vim.api.nvim_exec2('cclose', {})
      vim.notify(
        'There is nothing to display in the quickfix window',
        vim.log.levels.WARN
      )
    end
    if enter ~= true then vim.fn.win_gotoid(winid) end
  end
end, {
  nargs = '*',
  complete = function() return { 'toggle', 'open' } end,
})

---------------------------------------- Show messages in buffer with :Messages
vim.api.nvim_create_user_command('Msg', 'Messages', {})
vim.api.nvim_create_user_command('Messages', function()
  local buf = nil
  local ok, _ = pcall(function()
    vim.cmd 'noautocmd keepjumps 20split new'
    buf = vim.api.nvim_get_current_buf()
    local no_messages = 'There are no messages to display'
    local lines = nil
    vim.api.nvim_buf_call(buf, function()
      local output = vim.api.nvim_exec2('messages', { output = true })
      if type(output) == 'table' and type(output.output) == 'string' then
        local lns = vim.split(output.output, '\n')
        lns = vim.tbl_filter(function(l)
          return #l > 0 and l ~= no_messages and
            not l:match '^"(.-)"%s+%d+L,%s+%d+B'
        end
        , lns)
        lines = {}
        for i = #lns, 1, -1 do
          table.insert(lines, lns[i])
        end
      end
    end)
    if type(lines) ~= 'table' or not next(lines) then
      vim.notify(no_messages, vim.log.levels.WARN)
      vim.api.nvim_buf_delete(buf, { force = true })
      return
    end
    pcall(vim.api.nvim_buf_set_name, buf, 'Messages')
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'buftype', '')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'filetype', 'messages')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'buflisted', false)
    vim.api.nvim_buf_set_option(buf, 'modified', false)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'readonly', true)
    vim.keymap.set({ 'n', 'v' }, '<Esc>', ':bwipe!<CR>', { buffer = buf })
    vim.keymap.set({ 'n' }, 'q', ':bwipe!<CR>', { buffer = buf })
  end)
  if not ok then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end
end, {})
