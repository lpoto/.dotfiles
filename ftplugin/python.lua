--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PYTHON
--=============================================================================
-- Loaded when a python file is oppened.
--_____________________________________________________________________________

require("filetype")
  .new({
    copilot = true,
    -- pip install python-lsp-server
    lsp_server = "pylsp",
    -- pip install flake8
    linter = "flake8",
    -- pip install autopep8
    formatter = function()
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
  })
  :load()
