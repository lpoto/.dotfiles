--=============================================================================
-------------------------------------------------------------------------------
--                                                                 ACTIONS.NVIM
--=============================================================================
-- https://github.com/lpoto/actions.nvim
--_____________________________________________________________________________

local setups = {}

local actions = {}

---Commands used to open the actions window
actions.commands = { "A", "Action", "Actions" }

---Setup the actions plugin, use :Actions command
---to open the actions window, use <leader>e to toggle last output
---Use Ctrl-c to kill the action running in the oppened output window.
function actions.setup()
  require("actions").setup {}
  for _, config in ipairs(setups) do
    require("actions").setup(config)
  end
  vim.api.nvim_create_user_command("Actions", require("actions").open, {})
  vim.api.nvim_set_keymap(
    "n",
    "<leader>e",
    "<CMD>lua require('actions').toggle_last_output()<CR>",
    { noremap = true }
  )
end

---add a setup call to a table instead of calling it
---immediately, so it may be lazy loaded. If the plugin
---has already been loaded, call it instead.
---@param config table: actions config
local function add_setup(config)
  if package.loaded["actions"] ~= nil then
    require("actions").setup(config)
    return
  end
  table.insert(setups, config)
end

local distinct_setups = {}

---Create a distinct setup, identifies by the provided key.
---Once this is called, calling it again with the same key will
---be a no-op, unless override is true.
---
---NOTE: this is useful for setting local configs and ignoring
---the default distinct configs.
---
---@param key string: A string to identify the setup
---@param config table: An actions config
---@param override boolean?: Override existing config.
function actions.distinct_setup(key, config, override)
  if override ~= true and distinct_setups[key] ~= nil then
    return
  end
  add_setup(config)

  distinct_setups[key] = true
end

return actions
