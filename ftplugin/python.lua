--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PYTHON
--=============================================================================
-- Loaded when a python file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- LSPCONFIG
--github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#pylsp

-- NOTE: start pylsp language server for python
require("plugins.lspconfig").distinct_setup("python", function()
  --[[
      pip install pylsp
  ]]
  require("lspconfig").pylsp.setup {
    capabilities = require("plugins.cmp").default_capabilities(),
    root_dir = require "util.root",
  }

  vim.fn.execute("LspStart", true)
end)

------------------------------------------------------------------------ LINTER
--https://github.com/mfussenegger/nvim-lint

--NOTE: lint python with flake8
--[[
    pip install flake8
]]
require("plugins.lint").add_linters("python", { "flake8" }, true)

--------------------------------------------------------------------- FORMATTER
--github.com/mhartington/formatter.nvim/blob/master/lua/formatter/filetypes/python.lua

-- NOTE: set autopep8 as default python formatter
require("plugins.formatter").distinct_setup("python", {
  --[[
      pip install autopep8
  ]]
  filetype = {
    python = {
      function()
        return {
          exe = "python3 -m autopep8",
          args = {
            "--aggressive --aggressive --aggressive -",
          },
          stdin = true,
        }
      end,
    },
  },
})

--------------------------------------------------------------------- DEBUGGER
--github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python

-- NOTE: set debugpy as default python debugger
require("plugins.dap").distinct_setup("python_adapter", function(dap)
  --[[
      pip install debugpy
  ]]
  dap.adapters.python = {
    type = "executable",
    command = vim.fn.exepath "python",
    args = { "-m", "debugpy.adapter" },
    options = {
      detach = false,
    },
  }
end)

-- NOTE: debug currently oppened python file with debugpy
require("plugins.dap").distinct_setup("python_config", function(dap)
  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      pythonPath = function()
        return vim.fn.exepath "python"
      end,
    },
  }
end)

----------------------------------------------------------------------- ACTIONS
-- NOTE: set default actions

require("plugins.actions").distinct_setup("python", {
  actions = {
    ["Run current Python file"] = function()
      return {
        filetypes = { "python" },
        steps = {
          { "python3", vim.fn.expand "%:p" },
        },
      }
    end,
  },
})

----------------------------------------------------------------------- COPILOT
-- NOTE: enable github copilot if it is not already enabled

require("plugins.copilot").enable()
