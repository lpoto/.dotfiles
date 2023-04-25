--=============================================================================
-------------------------------------------------------------------------------
--                                                                         INIT
--=============================================================================
local safe_require

local function init()
  --------------------------------------------------------- Load custom options
  safe_require "config.options"
  --------------------------------------------------------- Load custom keymaps
  safe_require "config.keymaps"
  ---------------------------------------------------------- Load user commands
  safe_require "config.user_commands"
  ---------------------------------------------------- Load custom autocommands
  safe_require "config.autocommands"
  -------------------------------------------------------- Source local configs
  safe_require "config.local_config"
  --------------------------------------------- Load the plugins with lazy.nvim
  safe_require "config.lazy"
  ------------------------------------------- Load automatic session management
  safe_require "config.sessions"
  ---------------------------------------------------------- Load winbar config
  safe_require "config.winbar"
end

------------- Safely require a module, so other configs still load if one fails
---@param module string
function safe_require(module)
  local ok, e = pcall(require, module)
  if not ok and type(e) == "string" then
    vim.defer_fn(function()
      vim.notify(
        "Failed to load '" .. module .. "': " .. e,
        vim.log.levels.ERROR,
        {
          title = "INIT",
        }
      )
    end, 500)
  end
end

init()
