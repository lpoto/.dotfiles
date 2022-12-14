--=============================================================================
-------------------------------------------------------------------------------
--                                                                        OCAML
--=============================================================================
-- Loaded when an OCaml file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- LSPCONFIG
--github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ocamllsp

-- NOTE: set ocamllsp the default lsp server for OCaml
local lspconfig = require("util.packer_wrapper").get "lspconfig"

lspconfig:config(function()
  --[[
      opam install ocaml-lsp-server
  ]]
  require("lspconfig").ocamllsp.setup {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    root_dir = require "util.root",
  }

  vim.fn.execute("LspStart", true)
end, "ocaml")

lspconfig:run "start"

--------------------------------------------------------------------- FORMATTER
--github.com/mhartington/formatter.nvim/blob/master/lua/formatter/filetypes/ocaml.lua

local formatter = require("util.packer_wrapper").get "formatter"

-- NOTE: set ocamlformat as the default formatter for OCaml
formatter:config(function()
  --[[
      opam install ocamlformat
  ]]
  require("formatter").setup {
    filetype = {
      ocaml = {
        function()
          return {
            exe = "eval $(opam config env) && ocamlformat",
            args = {
              "--enable-outside-detected-project",
              vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)),
            },
            stdin = true,
          }
        end,
      },
    },
  }
end, "ocaml")

----------------------------------------------------------------------- ACTIONS
-- NOTE: set default actions

local actions = require("util.packer_wrapper").get "actions"

actions:config(function()
  require("actions").setup {
    actions = {
      -- Compile and run current ocaml file with ocamlopt
      ["Run current file with ocamlopt"] = function()
        return {
          steps = {
            {
              --compile the current file
              "ocamlopt",
              vim.fn.expand "%:p",
              "-o",
              vim.fn.expand "%:p:r" .. ".nvim",
            },
            {
              --run the compiled file
              (vim.fn.expand "%:p:r") .. ".nvim",
            },
            {
              --clean up
              "rm",
              (vim.fn.expand "%:p:r") .. ".nvim",
              (vim.fn.expand "%:p:r") .. ".cmi",
              (vim.fn.expand "%:p:r") .. ".cmx",
              (vim.fn.expand "%:p:r") .. ".o",
            },
          },
        }
      end,
    },
  }
end, "ocaml")

----------------------------------------------------------------------- COPILOT
-- NOTE: enable copilot for OCaml

local copilot = require("util.packer_wrapper").get "copilot"

copilot:run "enable"
