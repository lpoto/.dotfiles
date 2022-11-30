--=============================================================================
-------------------------------------------------------------------------------
--                                                                     NVIM-DAP
--=============================================================================
-- https://github.com/mfussenegger/nvim-dap
-- https://github.com/theHamsta/nvim-dap-virtual-text
--
--NOTE: this config focused on performing all actions through the
--dap's repl.
--The repl may be toggled and then it's commands listed with `.help`.
--_____________________________________________________________________________

local log = require "util.log"

local setup_functions = {}

---@type function
local extend_repl
---@type function
local set_user_commands

local M = {}

---dap defualt setup function called when the plugin is
---loaded. Calls all setups added with M.add_setup().
---Sets `D` user commands that opens 12 different dap options.
function M.init()
  local dap = require "dap"

  -- NOTE: load virtual text extension
  local ok, _ = pcall(require("nvim-dap-virtual-text").setup, {})
  if ok == false then
    log.warn "Failed loading dap extension: nvim-dap-virtual-text"
  end

  -- NOTE: add all other distinct setups
  for _, f in ipairs(setup_functions) do
    f(dap)
  end

  -- NOTE: extend the repl commands
  extend_repl()

  -- NOTE: set the user commands and remappings
  set_user_commands()

  -- NOTE: open repl immediately when starting the debuggin
  dap.listeners.after.event_initialized["custom"] = function()
    M.toggle_repl()
  end

  -- NOTE: higlight the breakpoint better
  vim.highlight.create(
    "DapBreakpoint",
    { ctermbg = 0, guifg = "#993939", guibg = "#31353f" },
    false
  )
  vim.fn.sign_define("DapBreakpoint", {
    text = "",
    texthl = "DapBreakpoint",
    linehl = "",
    numhl = "",
  })
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
function M.distinct_setup(key, f, override)
  if override ~= true and distinct_setups[key] ~= nil then
    return
  end
  add_setup(f)

  distinct_setups[key] = true
end

function M.toggle_repl()
  local dap = require "dap"
  local s = {}
  if vim.o.columns > 240 then
    s.width = 120
  end
  dap.repl.toggle(s, "vsplit")
  for _, v in ipairs(vim.api.nvim_list_wins()) do
    local b = vim.api.nvim_win_get_buf(v)
    if vim.api.nvim_buf_get_option(b, "filetype") == "dap-repl" then
      vim.fn.execute("keepjumps wincmd w ", v)
    end
  end
end

function M.terminate() end

extend_repl = function()
  local dap = require "dap"
  local repl = require "dap.repl"

  repl.commands = vim.tbl_extend("force", repl.commands, {
    exit = { ".exit", ".q", ".kill", ".terminate" },
    help = { ".h", "help" },
    scopes = { ".scopes", ".s" },
    frames = { ".frames", ".f" },
    custom_commands = {
      [".breakpoints"] = function()
        dap.list_breakpoints()
        vim.fn.execute "copen"
      end,
      [".clear_breakpoints"] = function()
        dap.clear_breakpoints()
      end,
    },
  })
end

set_user_commands = function()
  -- toggle repl vertical split with <leader> + d
  vim.api.nvim_set_keymap(
    "n",
    "<leader>d",
    "<CMD>lua require('plugins.dap').toggle_repl()<CR>",
    { noremap = true, silent = true }
  )

  -- Continue with Ctrl + d
  vim.api.nvim_set_keymap(
    "n",
    "<C-d>",
    "<CMD>lua require('dap').continue()<CR>",
    { noremap = true, silent = true }
  )

  -- Set breakpoint with Ctrl + b
  vim.api.nvim_set_keymap(
    "n",
    "<C-b>",
    "<CMD>lua require('dap').toggle_breakpoint()<CR>",
    { noremap = true, silent = true }
  )

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "dap-repl",
    command = "lua require('dap.ext.autocompl').attach()",
  })
end

return M
