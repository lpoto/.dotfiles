--=============================================================================
--                                                                         SPUR
--[[===========================================================================
--
-- Spur is a plugin that allows managing arbitrary jobs from a single
-- interface. It provides builtin extensions, ex. LazyGit for git management,
-- or LazySql as a database manager, etc.
--
-- NOTE: Also adds DAP plugin, as most of dap actions are managed through Spur.
--
-- Relevant commands:
--
-- <leader>s               (Spur job selector)
--
-- ... shortcuts for specific jobs
--
-----------------------------------------------------------------------------]]

vim.pack.add {
  {
    src = "https://github.com/lpoto/spur.nvim",
  },
  {
    src = "https://github.com/mfussenegger/nvim-dap",
    version = "0.10.0"
  }
}

vim.schedule(function()
  require "spur".setup {
    extensions = {
      "dap",
      --"makefile",
      "terminal",
      "lazygit",
      "lazysql",
      "json",
      "copilot"
    },
    mappings = {
      actions = { key = "<leader>s", mode = { "n" } },
    },
  }

  vim.keymap.set("n", "<leader>s", function() require "spur".select_job() end)
  vim.keymap.set("n", "<leader>o", function() require "spur".toggle_output() end)
  vim.keymap.set("n", "<leader>c",
    function() require "spur".select_job "[Copilot]" end)
  vim.keymap.set("n", "<leader>d",
    function() require "spur".select_job "[LazySql]" end)
  vim.keymap.set("n", "<leader>g",
    function() require "spur".select_job "[LazyGit]" end)
  vim.keymap.set("n", "<leader>db", function() vim.cmd "DapToggleBreakpoint" end)
  vim.keymap.set("n", "<leader>dc", function() vim.cmd "DapClearBreakpoints" end)
end)
