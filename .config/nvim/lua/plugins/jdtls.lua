--=============================================================================
-------------------------------------------------------------------------------
--                                                                   NVIM-JDTLS
--[[===========================================================================
https://github.com/mfussenegger/nvim-jdtls
-----------------------------------------------------------------------------]]

local M = {
  'mfussenegger/nvim-jdtls',
}

local util = {}

function M.init()
  util.set_up_autocommands()
end

function util.set_up_autocommands()
  vim.api.nvim_create_autocmd('Filetype', {
    group = vim.api.nvim_create_augroup('jdtls.Ft', { clear = true }),
    callback = util.filetype_autocommand
  })
end

function util.filetype_autocommand()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo.filetype
  local loaded = filetype .. '_jdtls_loaded'
  if vim.g[loaded] then return end

  vim.defer_fn(function()
    if vim.api.nvim_get_current_buf() ~= buf or
      vim.g[loaded] then
      return
    end
    vim.g[loaded] = true

    local opts = vim.g[filetype]
    if type(opts) == 'function' then
      local ok, v = pcall(opts)
      if not ok then
        return vim.api.nvim_err_writeln(
          'Error in filetype config function: ' .. v
        )
      end
      opts = v
      vim.g[filetype] = opts
    end
    util.attach(buf, opts)
  end, 200)
end

function util.attach(bufnr, opts)
  if type(opts) ~= 'table' then return end
  local server = opts.server or opts.language_server
  if type(server) == 'string' then server = { name = server } end
  if type(server) ~= 'table' then return end
  if server.name ~= 'jdtls' or type(vim.g.attached) == 'table' and
    vim.tbl_contains(vim.g.attached, server.name) then
    return
  end

  if type(server.root_dir) ~= 'string' then
    server.root_dir = util.find_root(bufnr)
  end
  if server.cmd == nil then
    local exe = vim.fn.exepath 'jdtls'
    if not exe or exe:len() == 0 then
      return util.add_to_not_attached(server.name)
    end
    server.cmd = {
      exe,
      '-data',
      vim.fn.stdpath 'cache' .. '/jdtls/workspace/' .. server.root_dir,
    }
  end
  server.autostart = true
  local group = vim.api.nvim_create_augroup('StartJdtls', { clear = true })
  vim.api.nvim_create_autocmd('Filetype', {
    group = group,
    pattern = 'java',
    callback = function()
      require 'jdtls'.start_or_attach(server)
    end,
  })
  vim.api.nvim_exec_autocmds('Filetype', { group = group })

  util.add_to_attached(server.name)
end

function util.find_root(buf)
  if type(buf) ~= 'number' or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_get_current_buf()
  end
  local patterns = {
    'mvn',
    'pom.xml',
    'settings.gradle',
    'settings.gradle.kts',
    'gradlew',
    'build.gradle',
    'build.gradle.kts',
    'build.xml',
  }
  local path = vim.api.nvim_buf_get_name(buf)
  local cwd = vim.fn.getcwd()
  local parents = {}
  local n = nil
  for parent in vim.fs.parents(path) do
    if type(n) == 'number' then
      if n == 0 then break end
      n = n - 1
    end
    ---@diagnostic disable-next-line
    if parent:len() <= 2 or parent == vim.uv.os_homedir() then break end
    table.insert(parents, 1, parent)
    if parent:len() <= cwd:len() then n = 2 end
  end
  for _ = 1, 2 do
    for _, parent in ipairs(parents) do
      for _, pattern in ipairs(patterns) do
        local p = parent .. '/' .. pattern
        if vim.fn.filereadable(p) == 1 then return parent end
      end
    end
    table.insert(patterns, '.git')
  end
  return cwd
end

function util.add_to_attached(name)
  local attached = vim.g.attached
  if type(attached) ~= 'table' then
    attached = {}
  end
  table.insert(attached, name)
  vim.g.attached = attached
end

function util.add_to_not_attached(name)
  local not_attached = vim.g.not_attached
  if type(not_attached) ~= 'table' then
    not_attached = {}
  end
  table.insert(not_attached, name)
  vim.g.not_attached = not_attached
end

return M
