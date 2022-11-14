--=============================================================================
-------------------------------------------------------------------------------
--                                                                     NVIM-DAP
--=============================================================================
-- https://github.com/mfussenegger/nvim-dap
-- https://github.com/theHamsta/nvim-dap-virtual-text
-- https://github.com/rcarriga/nvim-dap-ui
--_____________________________________________________________________________

local setup_functions = {}

local dap = {}

---dap defualt setup function called when the plugin is
---loaded. Calls all setups added with dap.add_setup().
function dap.setup()
  local dap_module = require "dap"
  local dapui_module = require "dapui"

  dapui_module.setup()
  require("nvim-dap-virtual-text").setup {}

  for _, f in ipairs(setup_functions) do
    f(dap_module)
  end
  vim.api.nvim_create_user_command("Dap", function()
    dap_module.continue()
  end, {})

  dap.ui_commands()

  dap_module.listeners.after.event_initialized["dapui_config"] = function()
    dapui_module.open {}
  end
end

---add a setup call to a table instead of calling it
---immediately, so it may be lazy loaded. If the plugin
---has already been loaded, call it instead.
---The setup should be a function that recieves dap module as
---a parameter.
---@param f function:  dap setup function
local function add_setup(f)
  if package.loaded["dap"] ~= nil then
    return
  end
  table.insert(setup_functions, f)
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
---@param f function: A debugger config function
---@param override boolean?: Override existing config.
function dap.distinct_setup(key, f, override)
  if override ~= true and distinct_setups[key] ~= nil then
    return
  end
  add_setup(f)

  distinct_setups[key] = true
end

function dap.ui_commands()
  vim.api.nvim_create_user_command("DapuiOpen", function()
    require("dapui").open {}
  end, {})
  vim.api.nvim_create_user_command("DapuiClose", function()
    require("dapui").close {}
  end, {})
  vim.api.nvim_create_user_command("DapuiToggle", function()
    require("dapui").toggle {}
  end, {})
  vim.api.nvim_create_user_command("DapuiEval", function()
    vim.cmd "lua require('dapui').eval()"
  end, {})
end

return dap
