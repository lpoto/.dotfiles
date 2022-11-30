--=============================================================================
-------------------------------------------------------------------------------
--                                                                     NVIM-DAP
--=============================================================================
-- https://github.com/mfussenegger/nvim-dap
-- https://github.com/theHamsta/nvim-dap-virtual-text
--_____________________________________________________________________________

local setup_functions = {}

local widgets = {
  scopes = nil,
  frames = nil,
  expression = nil,
  threads = nil,
}

local dap = {}

---dap defualt setup function called when the plugin is
---loaded. Calls all setups added with dap.add_setup().
---Sets `D` user commands that opens 12 different dap options.
function dap.setup()
  local dap_module = require "dap"

  require("nvim-dap-virtual-text").setup {}

  for _, f in ipairs(setup_functions) do
    f(dap_module)
  end

  vim.api.nvim_create_user_command("D", function()
    dap.dap()
  end, {})
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

function dap.dap()
  local dap_module = require "dap"
  local choice = vim.fn.confirm(
    "Select a dap action:",
    "&c-Continue\n&b-ToggleBreakpoint\n&o-StepOver\n&i-StepInto\n"
      .. "&t-StepOut\n&k-StepBack\n&l-ListBreakpoints\nx-ClearBreakpoints"
      .. "\n&r-OpenRepl\n&s-ShowScopes\n&e-EvalExpression"
      .. "\n&t-Terminate"
  )
  if choice == 1 then
    dap_module.continue()
  elseif choice == 2 then
    dap_module.toggle_breakpoint()
  elseif choice == 3 then
    dap_module.step_over()
  elseif choice == 4 then
    dap_module.step_into()
  elseif choice == 5 then
    dap_module.step_out()
  elseif choice == 6 then
    dap_module.step_back()
  elseif choice == 7 then
    dap_module.list_breakpoints()
    vim.fn.execute "copen"
  elseif choice == 8 then
    dap_module.clear_breakpoints()
  elseif choice == 9 then
    dap_module.repl.open()
  elseif choice == 10 then
    dap.open_scopes()
  elseif choice == 11 then
    dap.eval_expression()
  elseif choice == 12 then
    dap_module.terminate()
  end
end

function dap.open_scopes()
  local w = require "dap.ui.widgets"
  if widgets.scopes == nil then
    widgets.scopes = w.sidebar(w.scopes)
  end
  widgets.scopes.open()
  widgets.scopes.refresh()
end

function dap.open_frames()
  local w = require "dap.ui.widgets"
  if widgets.frames == nil then
    widgets.frames = w.sidebar(w.frames)
  end
  widgets.frames.open()
  widgets.frames.refresh()
end

function dap.eval_expression()
  local w = require "dap.ui.widgets"
  if widgets.expression == nil then
    widgets.expression = w.sidebar(w.expression)
  end
  widgets.expression.open()
  widgets.expression.refresh()
end

function dap.open_threads()
  local w = require "dap.ui.widgets"
  if widgets.threads ~= nil then
    widgets.threads = w.sidebar(w.threads)
  end
  widgets.threads.open()
end

return dap
