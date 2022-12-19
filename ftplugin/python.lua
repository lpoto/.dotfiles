--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PYTHON
--=============================================================================
-- Loaded when a python file is opened.
--_____________________________________________________________________________

local filetype = require "filetype"

filetype.config {
  filetype = "python",
  priority = 0,
  copilot = true, -- :Copilot setup
  lsp_server = "pylsp", -- pip install python-lsp-server
  linter = "flake8", -- pip install flake8
  formatter = function() -- pip install autopep8
    return {
      exe = "python3 -m autopep8",
      args = {
        "--aggressive --aggressive --aggressive -",
      },
      stdin = true,
    }
  end,
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
        -- pip install debugpy
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
        -- Debug current Python file
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
