--=============================================================================
-------------------------------------------------------------------------------
--                                                                         INIT
--=============================================================================
if not pcall(function() assert(type(vim.snippet) == 'table') end) then
  return print 'This configuration requires NVIM v0.10.0 or newer.'
end

local ok, e = pcall(function()
  require 'config.options'
  require 'config.highlights'
  require 'config.keymaps'
  require 'config.lsp'
  require 'config.lazy'
end)
if not ok then
  vim.notify('Error loading config module: ' .. e, vim.log.levels.ERROR)
end
