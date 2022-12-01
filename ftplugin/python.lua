--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PYTHON
--=============================================================================
-- Loaded when a python file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- LSPCONFIG
-- NOTE: start pylsp language server for python

require("plugins.lspconfig").distinct_setup("python", function()
  require("lspconfig").pylsp.setup {
    capabilities = require("plugins.cmp").default_capabilities(),
    root_dir = require("util").get_root,
  }

  vim.fn.execute("LspStart", true)
end)

--------------------------------------------------------------------- FORMATTER
-- NOTE: set autopep8 as default python formatter

require("plugins.formatter").distinct_setup("python", {
  -- install python3, python3-pip and python3-venv
  -- install autopep8 with pip
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
-- NOTE: set debugpy as default python debugger

-- [[ pip install debugpy ]]
require("plugins.dap").distinct_setup("python_adapter", function(dap)
  dap.adapters.python = {
    type = "executable",
    command = vim.fn.exepath "python",
    args = { "-m", "debugpy.adapter" },
    options = {
      detach = false,
    },
  }
end)

-- debug currently oppened file with debugpy
require("plugins.dap").distinct_setup("python_config", function(dap)
  -- Options below are for debugpy, see:
  -- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
  -- for supported options
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
    -- Run currently oppened python file
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
