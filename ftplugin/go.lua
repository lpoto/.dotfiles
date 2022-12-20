--=============================================================================
-------------------------------------------------------------------------------
--                                                                           GO
--=============================================================================
-- Loaded when a Go file is opened.
-- Install required servers, linters and formatters with:
--
--                        :MasonInstall <pkg>
--
-- To see available linters and formatters for current filetype, run:
--
--                        :NullLsInfo
--
-- To see attached language server for current filetype, run:
--
--                        :LspInfo
--_____________________________________________________________________________

local filetype = require "filetype"

filetype.config {
  filetype = "go",
  priority = 1,
  copilot = true,
  language_server = "gopls",
  formatter = "goimports",
  --linter = "golangci_lint",
}

-- Configure actions and debuggers
filetype.config {
  filetype = "go",
  priority = 0,
  actions = {
    ["Run current Go file"] = function()
      return {
        filetypes = { "go" },
        steps = {
          { "go", "run", vim.api.nvim_buf_get_name(0) },
        },
      }
    end,
  },
  debugger = {
    adapters = {
      delve = {
        type = "server",
        port = "${port}",
        executable = {
          command = "dlv",
          args = { "dap", "-l", "127.0.0.1:${port}" },
          detached = false,
        },
      },
    },
    configurations = {
      {
        type = "delve",
        name = "Debug",
        request = "launch",
        program = "${file}",
        dlvToolPath = vim.fn.exepath "dlv",
      },
    },
  },
}

filetype.load "go"
