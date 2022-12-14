--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PYTHON
--=============================================================================
-- Loaded when a python file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- LSPCONFIG
--github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#pylsp

-- NOTE: start pylsp language server for python
local lspconfig = require("util.packer_wrapper").get "lspconfig"

lspconfig:config(function()
  --[[
      pip install pylsp
  ]]
  require("lspconfig").pylsp.setup {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    root_dir = require "util.root",
  }
end, "python")

lspconfig:run "start"

------------------------------------------------------------------------ LINTER
--https://github.com/mfussenegger/nvim-lint

local lint = require("util.packer_wrapper").get "lint"

--NOTE: lint python with flake8
--[[
    pip install flake8
]]
lint:config(function()
  require("lint").linters_by_ft["python"] = { "flake8" }
end, "python")

--------------------------------------------------------------------- FORMATTER
--github.com/mhartington/formatter.nvim/blob/master/lua/formatter/filetypes/python.lua

local formatter = require("util.packer_wrapper").get "formatter"

-- NOTE: set autopep8 as default python formatter
formatter:config(function()
  --[[
      pip install autopep8
  ]]
  require("formatter").setup {
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
  }
end, "python")

--------------------------------------------------------------------- DEBUGGER
--github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python

local dap = require("util.packer_wrapper").get "dap"

-- NOTE: set debugpy as default python debugger
dap:config(function()
  --[[
      pip install debugpy
  ]]
  require("dap").adapters.python = {
    type = "executable",
    command = vim.fn.exepath "python",
    args = { "-m", "debugpy.adapter" },
    options = {
      detach = false,
    },
  }
end, "python_adapter")

-- NOTE: debug currently oppened python file with debugpy
dap:config(function()
  require("dap").configurations.python = {
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
end, "python_debugger")

----------------------------------------------------------------------- ACTIONS
-- NOTE: set default actions

local actions = require("util.packer_wrapper").get "actions"

actions:config(function()
  require("actions").setup {
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
  }
end, "python")

----------------------------------------------------------------------- COPILOT
-- NOTE: enable github copilot if it is not already enabled

local copilot = require("util.packer_wrapper").get "copilot"

copilot:run "enable"
