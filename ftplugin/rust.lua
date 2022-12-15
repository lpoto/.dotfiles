--=============================================================================
-------------------------------------------------------------------------------
--                                                                         RUST
--=============================================================================
-- Loaded when a rust file is oppened.
--_____________________________________________________________________________

require("filetype")
  .new({
    copilot = true,
    -- rustup component add rust-analyzer
    lsp_server = {
      "rust_analyzer",
      {
        cmd = { "rustup", "run", "stable", "rust-analyzer" },
      },
    },
    -- rustup component add rustfmt
    formatter = function()
      return {
        exe = "rustup run stable rustfmt",
        stdin = true,
      }
    end,
    actions = {
      ["Run current Cargo binary"] = function()
        return {
          filetypes = { "rust" },
          patterns = { ".*/src/bin/[^/]+.rs" },
          cwd = require "root" { ".git", "cargo.toml" },
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
          cwd = require "root" { ".git", "cargo.toml" },
          steps = {
            { "cargo", "run" },
          },
        }
      end,
    },
  })
  :load()
