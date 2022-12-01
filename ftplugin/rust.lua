--=============================================================================
-------------------------------------------------------------------------------
--                                                                         RUST
--=============================================================================
-- Loaded when a rust file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- LSPCONFIG
-- NOTE: set rust-analyzer the default lsp server for rust

--[[ rustup update ]]
--[[ rustup component add rust-analyzer ]]
-- make sure to export path to rust-analyzer so command "rust-analyzer" exists.
require("plugins.lspconfig").distinct_setup("rust", function()
  require("lspconfig").rust_analyzer.setup {
    capabilities = require("plugins.cmp").default_capabilities(),
    root_dir = function()
      return require("util").get_root { ".git", ".gitignore", "Cargo.toml" }
    end,
  }
  -- NOTE: Start the lsp server
  vim.fn.execute("LspStart", true)
end)

--------------------------------------------------------------------- FORMATTER
-- NOTE: set rust as the default formatter for rust

require("plugins.formatter").distinct_setup("rust", {
  filetype = {
    rust = {
      function()
        return {
          exe = "rustfmt",
          stdin = true,
        }
      end,
    },
  },
})

----------------------------------------------------------------------- ACTIONS
-- NOTE: set default actions

require("plugins.actions").distinct_setup("rust", {
  actions = {
    -- Run currently oppened rust file
    ["Run current Cargo binary"] = function()
      return {
        filetypes = { "rust" },
        steps = {
          { "cargo", "run", "--bin", vim.fn.expand "%:p:t:r" },
        },
      }
    end,
  },
})
