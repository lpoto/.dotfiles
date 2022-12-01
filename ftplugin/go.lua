--=============================================================================
-------------------------------------------------------------------------------
--                                                                           GO
--=============================================================================
-- Loaded when a Go file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- LSPCONFIG
-- NOTE: set gopls the default lsp server for Go

require("plugins.lspconfig").distinct_setup("go", function()
  -- Install gopls with:
  -- go install golang.org/x/tools/gopls@latest

  require("lspconfig").gopls.setup {
    capabilities = require("plugins.cmp").default_capabilities(),
  }

  vim.cmd 'silent! exec "LspStart"'
end)

--------------------------------------------------------------------- FORMATTER
-- NOTE: set goimports as the default formatter for Go

require("plugins.formatter").distinct_setup("go", {
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
