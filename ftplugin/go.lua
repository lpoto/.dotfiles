--=============================================================================
-------------------------------------------------------------------------------
--                                                                           GO
--=============================================================================
-- Loaded when a Go file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- LSPCONFIG
--github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls

-- NOTE: set gopls the default lsp server for Go
local lspconfig = require("util.packer_wrapper").get "lspconfig"

lspconfig:config(function()
  --[[
      go install golang.org/x/tools/gopls@latest
  ]]
  require("lspconfig").gopls.setup {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
  }

  vim.cmd 'silent! exec "LspStart"'
end, "go")

lspconfig.data.start()

--------------------------------------------------------------------- FORMATTER
--github.com/mhartington/formatter.nvim/blob/master/lua/formatter/filetypes/go.lua

local formatter = require("util.packer_wrapper").get "formatter"

-- NOTE: set goimports as the default formatter for Go
formatter:config(function()
  --[[
      go install golang.org/x/tools/cmd/goimports@latest
  ]]
  require("formatter").setup {
    filetype = {
      go = {
        function()
          return {
            exe = "goimports",
            stdin = true,
          }
        end,
      },
    },
  }
end, "go")
---------------------------------------------------------------------- DEBUGGER
--https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#Go

local dap = require("util.packer_wrapper").get "dap"

-- NOTE: set delve as default golang dap adapter
dap:config(function()
  --[[
      go install github.com/go-delve/delve/cmd/dlv@latest
  ]]
  require("dap").adapters.delve = {
    type = "server",
    port = "${port}",
    executable = {
      command = "dlv",
      args = { "dap", "-l", "127.0.0.1:${port}" },
    },
    options = {
      detach = false,
    },
  }
end, "go_adapter")

-- NOTE: debug currently oppened file with delve
dap:config(function()
  require("dap").configurations.go = {
    {
      type = "delve",
      name = "Debug",
      request = "launch",
      program = "${file}",
    },
  }
end, "go_debugger")

----------------------------------------------------------------------- ACTIONS
-- NOTE: set default actions

local actions = require("util.packer_wrapper").get "actions"

actions:config(function()
  require("actions").setup {
    actions = {
      ["Run current Go file"] = function()
        return {
          filetypes = { "go" },
          steps = {
            { "go", "run", vim.fn.expand "%:p" },
          },
        }
      end,
    },
  }
end, "go")

----------------------------------------------------------------------- COPILOT
-- NOTE: enable copilot for go

local copilot = require("util.packer_wrapper").get "copilot"

copilot.data.enable()
