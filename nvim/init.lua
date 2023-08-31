--=============================================================================
-------------------------------------------------------------------------------
--                                                                         INIT
--=============================================================================

--------- NOTE: Ensure version 0.9.0 or higher of Neovim is running. Otherwise,
------------------- some newer feeatures may not be available and cause errors.
local _, version = pcall((vim or {}).version)
if
  type(version) ~= "table"
  or type(version.major) ~= "number"
  or version.major < 1
    and (type(version.minor) ~= "number" or version.minor < 9)
then
  print("This configuration requires Neovim 0.9.0 or greater.")
  return
end

-- NOTE: This configuration cannot run on Windows, since it uses Unix-specific
------------------------------------------------- features and configurations.
if vim.loop.os_uname().sysname == "Windows" then
  print("This configuration does not support Windows.")
  return
end

Util = require("util"):init({ log_level = vim.log.levels.DEBUG })

---- NOTE: Safely require modules with Util.require, so that they are loaded in
------------------------------------- order, even if one of them fails to load.

Util.require("config.options") -------------------- Load default editor options
Util.require("config.keymaps") ---- Load custom keymaps (not including plugins)
Util.require("config.lazy") ----------------------- Load plugins with lazy.nvim
