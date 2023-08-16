--=============================================================================
-------------------------------------------------------------------------------
--                                                                         INIT
--=============================================================================

Util = require("util"):init({ log_level = "DEBUG" })

-- NOTE:  Safely require modules with Util.require, so that they are loaded
-- in order, even if one of them fails to load.

Util.require("config.options") --------------------- Load default editor options
Util.require("config.keymaps") ----- Load custom keymaps (not including plugins)
Util.require("config.autocommands") ------------------- Load custom autocommands
Util.require("config.lazy") ------------------------ Load plugins with lazy.nvim

vim.api.nvim_create_autocmd("SourceCmd", {
  pattern = "*go.lua",
  callback = function(opts, arg2, arg3)
    Util.log():info(opts, arg2, arg3)
    local ok, e = pcall(function()
      if type(opts) == "table" and type(opts.file) == "string" then
        vim.api.nvim_exec("source " .. opts.file, false)
      end
    end)
    if not ok then
      Util.log():warn(e)
    end
  end,
})
