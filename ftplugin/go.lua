--=============================================================================
-------------------------------------------------------------------------------
--                                                                           GO
--=============================================================================
-- Loaded when a Go file is oppened.
--_____________________________________________________________________________

require("filetype")
  .new({
    copilot = true,
    -- go install golang.org/x/tools/gopls@latest lsp_server = "gopls",
    -- go install golang.org/x/tools/cmd/goimports@latest
    formatter = function()
      return {
        exe = "goimports",
        stdin = true,
      }
    end,
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
        --  go install github.com/go-delve/delve/cmd/dlv@latest
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
          -- Debug current Go file
          type = "delve",
          name = "Debug",
          request = "launch",
          program = "${file}",
          dlvToolPath = vim.fn.exepath "dlv",
        },
      },
    },
  })
  :load()
