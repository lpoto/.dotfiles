--=============================================================================
-------------------------------------------------------------------------------
--                                                                     NVIM-DAP
--=============================================================================
-- https://github.com/mfussenegger/nvim-dap
-- https://github.com/theHamsta/nvim-dap-virtual-text
--_____________________________________________________________________________

--[[
A Debug Adapter Protocol client implementation.
This config focused on performing all actions through the dap's repl.
The repl may be toggled and then it's commands listed with `.help`.
Includes a plugin to display virtual text for the debugger.

See github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
for adapter installation and configurations.

Keymaps:
  - "<leader>dr" - toggle the repl
  - "<leader>dn" - continue (or start)
  - "<lader>db" - toggle breakpoint

--]]

local M = {
  "mfussenegger/nvim-dap",
  cmd = { "DapContinue", "DapToggleBreakpoint" },
  keys = { "<leader>dr", "<leader>dn", "<leader>db" },
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
  },
}

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

function M.config()
  local dap = require "dap"
  local repl = require "dap.repl"

  local ok, _ = pcall(require("nvim-dap-virtual-text").setup, {})
  if ok == false then
    vim.notify(
      "Failed loading dap extension: nvim-dap-virtual-text",
      vim.log.levels.WARN
    )
  end

  -- NOTE: open repl immediately when starting the debuggin
  dap.listeners.after.event_initialized["custom"] = function()
    local toggle = true
    for _, v in ipairs(vim.api.nvim_list_wins()) do
      local b = vim.api.nvim_win_get_buf(v)
      if vim.api.nvim_buf_get_option(b, "filetype") == "dap-repl" then
        toggle = false
      end
    end
    if toggle == true then
      M.toggle_repl()
    end
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

  repl.commands = vim.tbl_extend("force", repl.commands, {
    exit = { ".exit", ".q", ".kill", ".terminate" },
    help = { ".h", "help", ".help" },
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

  -- toggle repl vertical split with <Alt> + r
  vim.api.nvim_set_keymap(
    "n",
    "<leader>dr",
    "<CMD>lua require('plugins.dap').toggle_repl()<CR>",
    { noremap = true }
  )

  -- Continue with <Alt>n
  vim.api.nvim_set_keymap(
    "n",
    "<leader>dn",
    "<CMD>lua require('dap').continue()<CR>",
    {
      noremap = true,
    }
  )

  -- Set breakpoint with Alt b
  vim.api.nvim_set_keymap(
    "n",
    "<leader>db",
    "<CMD>lua require('dap').toggle_breakpoint()<CR>",
    {
      noremap = true,
    }
  )

  local plugin_config = require "plugins.dap"
  dap.adapters = plugin_config.adapters or {}
  dap.configurations = plugin_config.configurations or {}
  plugin_config.adapters = nil
  plugin_config.configurations = nil
end

---Add adapters to the plugin's config, this is lazily loaded.
---
---@param adapters table: A table of adapters
function M.add_adapters(adapters)
  if M.adapters == nil then
    M.adapters = {}
  end

  if adapters ~= nil then
    for k2, v2 in pairs(adapters) do
      if package.loaded["dap"] ~= nil then
        require("dap").adapters[k2] = v2
      else
        M.adapters[k2] = v2
      end
    end
  end
end

---Add configurations to the plugin's config, this is lazily loaded.
---
---@param configurations table: A table of configurations
---@param filetype string?: Filetype or current filetype if nil
function M.add_configurations(configurations, filetype)
  if M.configurations == nil then
    M.configurations = {}
  end
  filetype = filetype or vim.o.filetype

  if configurations == nil then
    return
  end

  if configurations[1] == nil then
    for k2, v2 in pairs(configurations) do
      if package.loaded["dap"] ~= nil then
        require("dap").configurations[k2] = v2
      else
        M.configurations[k2] = v2
      end
    end
  else
    assert(type(filetype) == "string")
    if package.loaded["dap"] ~= nil then
      require("dap").configurations[filetype] = configurations
    else
      M.configurations[filetype] = configurations
    end
  end
end

return M
