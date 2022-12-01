--=============================================================================
-------------------------------------------------------------------------------
--                                                                           GO
--=============================================================================
-- Loaded when a Go file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- LSPCONFIG
--github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls

-- NOTE: set gopls the default lsp server for Go
require("plugins.lspconfig").distinct_setup("go", function()
  --[[
      go install golang.org/x/tools/gopls@latest
  ]]
  require("lspconfig").gopls.setup {
    capabilities = require("plugins.cmp").default_capabilities(),
  }

  vim.cmd 'silent! exec "LspStart"'
end)

--------------------------------------------------------------------- FORMATTER
--github.com/mhartington/formatter.nvim/blob/master/lua/formatter/filetypes/go.lua

-- NOTE: set goimports as the default formatter for Go
require("plugins.formatter").distinct_setup("go", {
  --[[
      go install golang.org/x/tools/cmd/goimports@latest
  ]]
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
})
---------------------------------------------------------------------- DEBUGGER
--https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#Go

-- NOTE: set delve as default golang dap adapter
require("plugins.dap").distinct_setup("go_adapter", function(dap)
  --[[
      go install github.com/go-delve/delve/cmd/dlv@latest
  ]]
  dap.adapters.delve = {
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
end)

-- NOTE: debug currently oppened file with delve
require("plugins.dap").distinct_setup("go_config", function(dap)
  dap.configurations.go = {
    {
      type = "delve",
      name = "Debug",
      request = "launch",
      program = "${file}",
    },
  }
end)

----------------------------------------------------------------------- ACTIONS
-- NOTE: set default actions

require("plugins.actions").distinct_setup("go", {
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
})
