--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LSP
--[[===========================================================================
A collection of LSP related configurations

Keymaps:

  - "K"         -  Show the definition of symbol under the cursor

  - "gd"        -  Go to the definitions of symbol under cursor
  - "gi"        -  Go to the implementations of symbol under cursor
  - "gr"        -  Go to the references to the symbol under the cursor

  - "<leader>d" -  Show the diagnostics of the line under the cursor

  - "<leader>a" -  Show code actions for the current position
  - "<leader>r" -  Rename symbol under cursor
-----------------------------------------------------------------------------]]

local M = {}

---Attach tools as LSP clients. These tools will be added to the
---lsp server based on the functions provided in
---`vim.lsp.add_attach_condition`.
---
---@param ...table|string
---@diagnostic disable-next-line
vim.lsp.attach = function(...)
  for _, opts in ipairs { select(1, ...) } do
    local ok, e = pcall(M.attach, opts)
    if not ok and e then
      vim.notify(e, vim.log.levels.ERROR)
    end
  end
end

---Add a function used during vim.lsp.attach. The function receives
---the table containing the tool configs and should return a table
---with possible fields:
---    - attached: string or table of strings of tools that were attached
---    - missing: string or table of strings of tools that were not found
---    - non_executable: string or table of strings of non-executable tools
---@param opts {priority: number, fn: fun(opts, buf, ft): table?}
---@diagnostic disable-next-line
vim.lsp.add_attach_condition = function(opts)
  return M.add_attach_condition(opts)
end

function M.init()
  M.set_lsp_keymaps {}
  M.set_lsp_handlers()
end

function M.set_lsp_keymaps(opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

  vim.keymap.set('n', '<leader>e', M.open_diagnostic_float, opts)
  vim.keymap.set({ 'n', 'v' }, '<leader>a', vim.lsp.buf.code_action, opts)

  vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)
end

function M.set_lsp_handlers()
  if M.handlers_set then return end
  M.handlers_set = true
  local border = 'single'
  vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, {
      border = border,
    })
  vim.lsp.handlers['textDocument/signatureHelp'] =
    vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = border,
    })
  vim.diagnostic.config {
    float = { border = border },
    virtual_text = true,
    underline = { severity = 'Error' },
    severity_sort = true,
  }
end

function M.open_diagnostic_float()
  local n, _ = vim.diagnostic.open_float()
  if not n then
    vim.notify('No diagnostics found', vim.log.levels.WARN)
  end
end

---------------------------------------------------- lsp attach implementations

function M.attach(opts)
  if type(opts) == 'string' then opts = { name = opts } end
  if type(opts) ~= 'table' or type(opts.name) ~= 'string' then
    error 'Invalid options for attaching LSP client'
  end
  local buf = vim.api.nvim_get_current_buf()
  if not M.__logs then M.__logs = {} end
  vim.defer_fn(function()
    local t = nil
    vim.api.nvim_buf_call(buf, function()
      t = M.__attach(opts, buf)
    end)
    if type(t) ~= 'table' or not next(t) then return end
    local attached = t.attached
    if type(attached) == 'string' then attached = { attached } end
    if type(attached) == 'table' and next(attached) then
      if M.__logs.attached == nil then M.__logs.attached = {} end
      for _, v in ipairs(attached) do
        table.insert(M.__logs.attached, v)
      end
    end
    local missing = t.missing
    if type(missing) == 'string' then missing = { missing } end
    if type(missing) == 'table' and next(missing) then
      if M.__logs.missing == nil then M.__logs.missing = {} end
      for _, v in ipairs(missing) do
        table.insert(M.__logs.missing, v)
      end
    end
    local non_executable = t.non_executable
    if type(non_executable) == 'string' then
      non_executable = { non_executable }
    end
    if type(non_executable) == 'table' and next(non_executable) then
      if M.__logs.non_executable == nil then M.__logs.non_executable = {} end
      for _, v in ipairs(non_executable) do
        table.insert(M.__logs.non_executable, v)
      end
    end
    vim.defer_fn(function()
      if not next(M.__logs) then return end
      local l = vim.log.levels.INFO
      local s = ''
      if next(M.__logs.attached or {}) then
        s = 'Attached: [' .. table.concat(M.__logs.attached, ', ') .. ']'
      end
      if next(M.__logs.non_executable or {}) then
        if s:len() > 0 then s = s .. ', ' end
        s = s
          .. 'No executables found for: ['
          .. table.concat(M.__logs.non_executable, ', ')
          .. ']'
        l = vim.log.levels.WARN
      end
      if next(M.__logs.missing or {}) then
        if s:len() > 0 then s = s .. ', ' end
        s = s
          .. 'No tools found for: ['
          .. table.concat(M.__logs.missing, ', ')
          .. ']'
        l = vim.log.levels.WARN
      end
      if s:len() > 0 then vim.notify(s, l) end
      M.__logs = {}
    end, 100)
  end, 50)
end

function M.__attach(opts, buffer)
  opts = vim.tbl_deep_extend(
    'force',
    opts or {},
    vim.g[opts.name .. '_config'] or {}
  )
  if type(opts.name) ~= 'string' then return end
  for _, o in pairs(vim.tbl_values(M.__attach_conditions or {})) do
    if type(o) == 'table' and type(o.fn) == 'function' then
      local f = o.fn
      local ok, v = pcall(f, opts, buffer)
      if not ok then
        vim.notify('Error attaching ' .. opts.name .. ': ' .. v,
          vim.log.levels.WARN
        )
      end
      if
        type(v) == 'table'
        and (
          type(v.missing) ~= 'table'
          or not vim.tbl_contains(v.missing, opts.name)
        )
      then
        return v
      end
    end
  end
  return { missing = { opts.name } }
end

function M.add_attach_condition(opts)
  if
    type(opts) ~= 'table'
    or type(opts.priority) ~= 'number'
    or type(opts.fn) ~= 'function'
  then
    return false
  end
  if type(M.__attach_conditions) ~= 'table' then
    M.__attach_conditions = {}
  end
  table.insert(M.__attach_conditions, opts)
  table.sort(
    M.__attach_conditions,
    function(a, b) return a.priority > b.priority end
  )
  return true
end

return M.init()
