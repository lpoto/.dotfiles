--=============================================================================
-------------------------------------------------------------------------------
--                                                                     NVIM-DAP
--=============================================================================
-- https://github.com/mfussenegger/nvim-dap
-- https://github.com/theHamsta/nvim-dap-virtual-text
--
--NOTE: this config focused on performing all actions through the dap's repl.
--The repl may be toggled and then it's commands listed with `.help`.
--_____________________________________________________________________________

-- continue with <leader>r
-- toggle breakpoint with <leader>b
-- toggle repl with <leader>r
local plugin = require("plugin").new {
  "mfussenegger/nvim-dap",
  as = "dap",
  cmd = { "DapContinue", "DapToggleBreakpoint" },
  keys = { "<leader>c", "<leader>b" },
  requires = {
    {
      "theHamsta/nvim-dap-virtual-text",
      --NOTE: this expects treesitter to be loaded
      module = "nvim-dap-virtual-text",
    },
  },
  config = function(dap)
    local log = require "log"

    local ok, _ = pcall(require("nvim-dap-virtual-text").setup, {})
    if ok == false then
      log.warn "Failed loading dap extension: nvim-dap-virtual-text"
    end

    -- NOTE: add all other distinct setups
    for _, f in ipairs(setup_functions) do
      f(dap)
    end

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
  end,
}

plugin:config(function(dap)
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
end)

plugin:config(function()
  local mapper = require "mapper"

  -- toggle repl vertical split with <leader> + r
  mapper.map(
    "n",
    "<leader>r",
    "<CMD>lua require('plugin').get('dap'):run('toggle_repl')<CR>"
  )

  -- Continue with Ctrl + d
  mapper.map("n", "<C-d>", "<CMD>lua require('dap').continue()<CR>")

  -- Set breakpoint with Ctrl + b
  mapper.map("n", "<C-b>", "<CMD>lua require('dap').toggle_breakpoint()<CR>")
end)

plugin:action("toggle_repl", function()
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
end)
