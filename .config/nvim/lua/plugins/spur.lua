--=============================================================================
--                                           https://github.com/lpoto/spur.nvim
--=============================================================================

return {
  "lpoto/spur.nvim",
  dependencies = {
    {
      "mfussenegger/nvim-dap",
      cmd = { "DapToggleBreakpoint" },
      tag = "0.10.0"
    },
    {
      "theHamsta/nvim-dap-virtual-text",
      commit = "fbdb48c",
      opts = {}
    }
  },
  keys = {
    { "<leader>s",  function() require "spur".select_job() end },
    { "<leader>o",  function() require "spur".toggle_output() end },
    { "<leader>db", function() vim.cmd "DapToggleBreakpoint" end },
    { "<leader>dc", function() vim.cmd "DapClearBreakpoints" end },
  },
  opts = {
    extensions = {
      "dap",
      "makefile",
      "json",
    }
  }
}
