--=============================================================================
-------------------------------------------------------------------------------
--                                                                           GO
--=============================================================================
-- Loaded when a Go file is oppened.
--_____________________________________________________________________________

require("filetype")
  .new({
    copilot = true,
    -- go install golang.org/x/tools/gopls@latest
    lsp_server = "gopls",
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
            { "go", "run", vim.fn.expand "%:p" },
          },
        }
      end,
    },
  })
  :load()
