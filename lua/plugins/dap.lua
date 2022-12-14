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

local dap = require("util.packer_wrapper").get "dap"

---dap defualt setup function called when the plugin is
---loaded. Calls all setups added with M.add_setup().
---Sets `D` user commands that opens 12 different dap options.
dap:config(function()
  local log = require "util.log"
  local dap_module = require "dap"
  local repl = require "dap.repl"

  -- NOTE: load virtual text extension
  local ok, _ = pcall(require("nvim-dap-virtual-text").setup, {})
  if ok == false then
    log.warn "Failed loading dap extension: nvim-dap-virtual-text"
  end

  -- NOTE: extend the repl commands
  repl.commands = vim.tbl_extend("force", repl.commands, {
    exit = { ".exit", ".q", ".kill", ".terminate" },
    help = { ".h", "help" },
    scopes = { ".scopes", ".s" },
    frames = { ".frames", ".f" },
    custom_commands = {
      [".breakpoints"] = function()
        dap_module.list_breakpoints()
        vim.fn.execute "copen"
      end,
      [".clear_breakpoints"] = function()
        dap_module.clear_breakpoints()
      end,
    },
  })

  -- NOTE: open repl immediately when starting the debuggin
  dap_module.listeners.after.event_initialized["custom"] = function()
    dap.data.toggle_repl()
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
end)

---Set custom keymaps for the dap plugin.
dap:config(function()
  local mapper = require "util.mapper"
  -- toggle repl vertical split with <leader> + r
  mapper.map(
    "n",
    "<leader>r",
    "<CMD>lua require('util.packer_wrapper').get('dap').data.toggle_repl()<CR>"
  )

  -- Continue with Ctrl + d
  mapper.map("n", "<leader>c", "<CMD>lua require('dap').continue()<CR>")

  -- Set breakpoint with Ctrl + b
  mapper.map(
    "n",
    "<leader>b",
    "<CMD>lua require('dap').toggle_breakpoint()<CR>"
  )
end, "remappings")

---Define the toggle_repl for dap plugin
dap.data.toggle_repl = function()
  local dap_module = require "dap"
  local s = {}
  if vim.o.columns > 240 then
    s.width = 120
  end
  dap_module.repl.toggle(s, "vsplit")
  for _, v in ipairs(vim.api.nvim_list_wins()) do
    local b = vim.api.nvim_win_get_buf(v)
    if vim.api.nvim_buf_get_option(b, "filetype") == "dap-repl" then
      vim.fn.execute("keepjumps wincmd w ", v)
    end
  end
end
