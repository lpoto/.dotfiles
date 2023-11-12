--=============================================================================
-------------------------------------------------------------------------------
--                                                                         INIT
--=============================================================================
if not pcall(function() assert(type(vim.snippet) == 'table') end) then
  return print 'This configuration requires NVIM v0.10.0 or newer.'
end

local ok, e = pcall(vim.cmd.colorscheme, 'default')
if not ok then
  vim.api.nvim_err_writeln('Error loading colorscheme: ' .. e)
end

ok, e = pcall(function()
  require 'config.options'
  require 'config.autocommands'
  require 'config.keymaps'
  require 'config.lazy'
end)
if not ok then
  vim.api.nvim_err_writeln('Error loading config module: ' .. e)
end
