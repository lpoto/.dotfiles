--=============================================================================
-------------------------------------------------------------------------------
--                                                                         INIT
--=============================================================================
if vim.uv.os_uname().sysname == "Windows" then
  print("This configuration does not support Windows.")
  return
end

Util = require("util"):init({ log_level = "DEBUG" })

--[[ NOTE: Safely require modules with Util.require, so that they are loaded in
order, even if one of them fails to load. --]]

Util.require("config.options") -------------------- Load default editor options
Util.require("config.keymaps") ---- Load custom keymaps (not including plugins)
Util.require("config.autocommands") ------------------ Load custom autocommands
Util.require("config.lazy") ----------------------- Load plugins with lazy.nvim
