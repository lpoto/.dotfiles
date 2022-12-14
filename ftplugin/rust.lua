--=============================================================================
-------------------------------------------------------------------------------
--                                                                         RUST
--=============================================================================
-- Loaded when a rust file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- LSPCONFIG
--github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer

-- NOTE: set rust-analyzer the default lsp server for rust
local lspconfig = require("util.packer_wrapper").get "lspconfig"

lspconfig:config(function()
  --[[
      rustup component add rust-analyzer
  ]]
  require("lspconfig").rust_analyzer.setup {
    -- NOTE: because installed with rustup
    cmd = { "rustup", "run", "stable", "rust-analyzer" },
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    root_dir = function()
      return require "util.root" { ".git", ".gitignore", "Cargo.toml" }
    end,
  }
  -- NOTE: Start the lsp server
  vim.fn.execute("LspStart", true)
end, "rust")

lspconfig.data.start()

--------------------------------------------------------------------- FORMATTER
--github.com/mhartington/formatter.nvim/blob/master/lua/formatter/filetypes/rust.lua

local formatter = require("util.packer_wrapper").get "formatter"

-- NOTE: set rust as the default formatter for rust
formatter:config(function()
  --[[
      rustup component add rustfmt
  ]]
  require("formatter").setup {
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
  }
end, "rust")

----------------------------------------------------------------------- ACTIONS
-- NOTE: set default actions

local actions = require("util.packer_wrapper").get "actions"

actions:config(function()
  require("actions").setup {
    actions = {
      ["Run current Cargo binary"] = function()
        return {
          filetypes = { "rust" },
          patterns = { ".*/src/bin/[^/]+.rs" },
          cwd = require "util.root" { ".git", "cargo.toml" },
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
          cwd = require "util.root" { ".git", "cargo.toml" },
          steps = {
            { "cargo", "run" },
          },
        }
      end,
    },
  }
end, "rust")

----------------------------------------------------------------------- COPILOT
-- NOTE: enable copilot for rust

local copilot = require("util.packer_wrapper").get "copilot"

copilot.data.enable()
