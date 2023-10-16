--=============================================================================
-------------------------------------------------------------------------------
--                                                                         INIT
--=============================================================================

--------- NOTE: Ensure version 0.9.0 or higher of Neovim is running. Otherwise,
------------------- some newer feeatures may not be available and cause errors.
local _, version = pcall((vim or {}).version)
if
  type(version) ~= 'table'
  or type(version.major) ~= 'number'
  or version.major < 1
  and (type(version.minor) ~= 'number' or version.minor < 9)
then
  return print 'This configuration requires Neovim 0.9.0 or greater.'
end

--- NOTE: This configuration cannot run on Windows, since it uses Unix-specific
-------------------------------------------------- features and configurations.
if vim.loop.os_uname().sysname == 'Windows' then
  return print 'This configuration does not support Windows.'
end

-- Require all the default config files, including lazy.nvim that loads plugins
for _, k in ipairs {
  'options',
  'highlights',
  'keymaps',
  'commands',
  'lsp',
  'lazy',
} do
  local ok, e = pcall(require, 'config.' .. k)
  if not ok then
    vim.notify('Error loading ' .. k .. ': ' .. e, vim.log.levels.ERROR)
  end
end
