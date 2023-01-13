--=============================================================================
-------------------------------------------------------------------------------
--                                                                    INIT NVIM
--=============================================================================
--NOTE: all filetype specific configs are defined in file in ftplugin/

----------------------------------------------------------------------- OPTIONS
-- Load the default options defined in lua/config/options.lua

require "config.options"

----------------------------------------------------------------------- PLUGINS
-- Load all the plugins defined in lua/plugins/ with lazy.nvim

require "config.lazy"

-------------------------------------------------------------------------------
-- Lazy load some configs that are not needed for the initial UI

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    ------------------------------------------------------------ VERSION AND OS
    -- Notify the user when the version of neovim is too low, or
    -- when the OS is not linux or macos

    require("util.version").ensure(true, true)

    ------------------------------------------------------------------ SESSIONS
    -- Configure loading and saving sessions

    require("config.sessions").config()

    ---------------------------------------------------------------- REMAPPINGS
    -- Load the remappings defined in lua/config/remappings.lua

    require "config.remappings"

    -------------------------------------------------------------- LOCAL CONFIG
    -- Search for a local config file in the current dir or 2 dirs up
    -- (.nvim.lua  or .nvimrc or .exrc)

    require("config").init()
  end,
})
