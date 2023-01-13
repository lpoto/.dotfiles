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
  go = {
    language_server = "gopls",
    formatter = "goimports",
    --linter = "golangci_lint",
    --copilot = true,
  },
  rust = {
    language_server = "rust_analyzer",
    formatter = "rustfmt",
    --copilot=true,
  },
  python = {
    language_server = "pylsp",
    linter = "flake8",
    formatter = "autopep8",
    --copilot=true,
  },
  yaml = {
    language_server = "yamlls",
    linter = "yamllint",
    formatter = "yamlfmt",
    --copilot=true,
  },
  markdown = {
    formatter = "prettier",
    --copilot=true,
  },
  sh = {
    language_server = "bashls",
    linter = "shellcheck",
    formatter = "shfmt",
    --copilot=true,
  },
  css = {
    formatter = "prettier",
    language_server = "cssls",
    --copilot=true,
  },
  ruby = {
    language_server = "solargraph",
    formatter = "rubocop",
    --copilot=true,
  },
  html = {
    formatter = "prettier",
    language_server = "html",
    --copilot=true,
  },
  xhtml = {
    formatter = "prettier",
    language_server = "html",
    --copilot=true,
  },
  javascript = {
    language_server = "tsserver",
    formatter = "prettier",
    --copilot=true,
  },
  typescript = {
    language_server = "tsserver",
    formatter = "prettier",
    --copilot=true,
  },
  lua = {
    language_server = {
      "sumneko_lua",
      require "plugins.lsp.default.sumneko_lua",
    },
    formatter = "stylua",
    --copilot=true,
  },
}
