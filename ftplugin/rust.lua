--=============================================================================
-------------------------------------------------------------------------------
--                                                                         RUST
--=============================================================================
-- Loaded when a rust file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- LSPCONFIG
--github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer

-- NOTE: set rust-analyzer the default lsp server for rust
require("plugins.lspconfig").distinct_setup("rust", function()
  --[[
      rustup component add rust-analyzer
  ]]
  require("lspconfig").rust_analyzer.setup {
    -- NOTE: because installed with rustup
    cmd = { "rustup", "run", "stable", "rust-analyzer" },
    capabilities = require("plugins.cmp").default_capabilities(),
    root_dir = function()
      return require("util").get_root { ".git", ".gitignore", "Cargo.toml" }
    end,
  }
  -- NOTE: Start the lsp server
  vim.fn.execute("LspStart", true)
end)

--------------------------------------------------------------------- FORMATTER
--github.com/mhartington/formatter.nvim/blob/master/lua/formatter/filetypes/rust.lua

-- NOTE: set rust as the default formatter for rust
require("plugins.formatter").distinct_setup("rust", {
  --[[
      rustup component add rustfmt
  ]]
  filetype = {
    rust = {
      function()
        return {
          -- NOTE: ye rustup
          exe = "rustup run stable rustfmt",
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
    ["Run current Cargo binary"] = function()
      return {
        filetypes = { "rust" },
        patterns = { ".*/src/bin/[^/]+.rs" },
        cwd = require("util").get_root { ".git", "cargo.toml" },
        steps = {
          { "cargo", "run", "--bin", vim.fn.expand "%:p:t:r" },
        },
      }
    end,
    ["Run current Cargo project"] = function()
      return {
        filetypes = { "rust" },
        patterns = { ".*/src/.*.rs" },
        ignore_patterns = { ".*/src/bin/[^/]+.rs" },
        cwd = require("util").get_root { ".git", "cargo.toml" },
        steps = {
          { "cargo", "run" },
        },
      }
    end,
  },
})
