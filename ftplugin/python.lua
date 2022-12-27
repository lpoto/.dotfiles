--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PYTHON
--=============================================================================
-- Loaded when a python file is opened.
-- Install required servers, linters and formatters with:
--
--                        :MasonInstall <pkg>  (or :Mason)
--
-- To see available linters and formatters for current filetype, run:
--
--                        :NullLsInfo
--
-- To see attached language server for current filetype, run:
--
--                        :LspInfo
--_____________________________________________________________________________

local filetype = require "config.filetype"

filetype.config {
  filetype = "python",
  priority = 1,
  copilot = true,
  language_server = "pylsp",
  linter = "flake8",
  formatter = "autopep8",
}

-- Configure actions and debuggers
filetype.config {
  filetype = "python",
  priority = 1,
  actions = {
    ["Run current Python file"] = function()
      return {
        filetypes = { "python" },
        steps = {
          { "python3", vim.api.nvim_buf_get_name(0) },
        },
      }
    end,
  },
  debugger = {
    adapters = {
      python = {
        type = "executable",
        command = vim.fn.exepath "python",
        args = { "-m", "debugpy.adapter" },
        options = {
          detached = true,
        },
      },
    },
    configurations = {
      {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
          return vim.fn.exepath "python"
        end,
      },
    },
  },
}

filetype.load "python"
