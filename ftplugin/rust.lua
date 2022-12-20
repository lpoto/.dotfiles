--=============================================================================
-------------------------------------------------------------------------------
--                                                                         RUST
--=============================================================================
-- Loaded when a rust file is opened.
-- Install required servers, linters and formatters with:
--
--                        :MasonInstall <pkg>   (or :Mason)
--
-- To see available linters and formatters for current filetype, run:
--
--                        :NullLsInfo
--
-- To see attached language server for current filetype, run:
--
--                        :LspInfo
--_____________________________________________________________________________

local filetype = require "filetype"

filetype.config {
  filetype = "rust",
  priority = 1,
  copilot = true,
  language_server = "rust_analyzer",
  formatter = "rustfmt",
}

-- Configure actions and debuggers
filetype.config {
  filetype = "rust",
  priority = 0,
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
}

filetype.load "rust"
