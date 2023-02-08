--=============================================================================
-------------------------------------------------------------------------------
--                                                                         INIT
--=============================================================================
local safe_require

local function init()
  ------------------------------------------------- Load general neovim options
  safe_require "config.options"
  ------------------------------------ Load general neovim keymaps and commands
  safe_require "config.keymaps"
  --------------------------------------------- Load the plugins with lazy.nvim
  safe_require "config.lazy"
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
