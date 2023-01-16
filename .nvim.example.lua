--=============================================================================
-------------------------------------------------------------------------------
--                                                             FILETYPES CONFIG
--=============================================================================
-- A config for a filetype is loaded when that filetype is opened.
--
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

return {
  plugins = {
    copilot = {
      -- Disable copilot by default
      cond = false,
    },
  },
  go = {
    language_server = "gopls",
    formatter = "goimports",
    --linter = "golangci_lint",
  },
  rust = {
    language_server = "rust_analyzer",
    formatter = "rustfmt",
  },
  python = {
    language_server = "pylsp",
    linter = "flake8",
    formatter = "autopep8",
  },
  yaml = {
    language_server = "yamlls",
    linter = "yamllint",
    formatter = "yamlfmt",
  },
  markdown = {
    formatter = "prettier",
  },
  sh = {
    language_server = "bashls",
    linter = "shellcheck",
    formatter = "shfmt",
  },
  css = {
    formatter = "prettier",
    language_server = "cssls",
  },
  ruby = {
    language_server = "solargraph",
    formatter = "rubocop",
  },
  html = {
    formatter = "prettier",
    language_server = "html",
  },
  xhtml = {
    formatter = "prettier",
    language_server = "html",
  },
  javascript = {
    language_server = "tsserver",
    formatter = "prettier",
  },
  typescript = {
    language_server = "tsserver",
    formatter = "prettier",
  },
  lua = {
    language_server = {
      "sumneko_lua",
      require "plugins.lsp.default.sumneko_lua",
    },
    formatter = "stylua",
  },
}
