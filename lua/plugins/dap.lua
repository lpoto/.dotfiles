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

  vim.api.nvim_create_user_command("D", function(o)
    local _, v = next(o.fargs)
    dap.dap(v)
  end, {
    nargs = "*",
    complete = function()
      local t = {}
      for _, v in ipairs(dap.choices(dap_module)) do
        table.insert(t, v[2] .. " (" .. v[1] .. ")")
      end
      return t
    end,
  })

  dap_module.listeners.after.event_initialized["custom"] = function()
    dap.open_repl()
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

dap.choices = function(dap_module)
  return {
    { "c", "Continue", dap_module.continue },
    { "b", "ToggleBreakpoint", dap_module.toggle_breakpoint },
    { "o", "StepOver", dap_module.step_over },
    { "i", "StepInto", dap_module.step_into },
    { "u", "StepOut", dap_module.step_out },
    { "k", "StepBack", dap_module.step_back },
    { "l", "ListBreakpoints", dap.list_breakpoints },
    { "x", "ClearBreakpoints", dap_module.clear_breakpoints },
    { "r", "OpenRepl", dap.open_repl },
    { "s", "ShowScopes", dap.open_scopes },
    { "e", "EvalExpression", dap.eval_expression },
    { "t", "Terminate", dap_module.terminate },
  }
end

---@param arg string?
function dap.dap(arg)
  local dap_module = require "dap"
  local choices = dap.choices(dap_module)
  if type(arg) == "string" and string.len(arg) > 0 then
    arg = string.lower(arg)
    for _, v in pairs(choices) do
      if arg == v[1] or arg == string.lower(v[2]) then
        v[3]()
        return
      end
    end
  end

  local s = ""
  for _, v in ipairs(choices) do
    if string.len(s) > 0 then
      s = s .. "\n"
    end
    s = s .. "&" .. v[1] .. "-" .. v[2]
  end

  local choice = vim.fn.confirm("Select a dap action:", s)
  if choices[choice] ~= nil then
    choices[choice][3]()
  end
end

function dap.open_repl()
  local dap_module = require "dap"
  local s = {}
  if vim.o.columns > 200 then
    s.width = 100
  end
  dap_module.repl.open(s, "vsplit")
end

function dap.list_breakpoints()
  local dap_module = require "dap"
  dap_module.list_breakpoints()
  vim.fn.execute "vertical copen"
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
