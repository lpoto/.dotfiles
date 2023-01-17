--=============================================================================
-------------------------------------------------------------------------------
--                                                                    INIT NVIM
--=============================================================================
--NOTE: all filetype specific configs are defined in file in ftplugin/

-------------------- Load the default options defined in lua/config/options.lua
require "config.options"

-------------- Load the default remappings defined in lua/config/remappings.lua
require "config.remappings"

------------------- Load all the plugins defined in lua/plugins/ with lazy.nvim
require "config.lazy"

----------------- Lazy load some configs that are not needed for the initial UI
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  once = true,
  callback = function()
    ---------------- Notify the user when the version of neovim is too low, or
    ---------------- when the OS is not linux or macos
    require("util.version").ensure(true, true)

    ------------------------------------ Configure loading and saving sessions
    require("config.sessions").config()

    ----------------- Search for a local .nvim.lua config file in the current
    ----------------  or any of it's parent directories.
    require("config.local").config()

    require("config.folding").config()
  end,
})
