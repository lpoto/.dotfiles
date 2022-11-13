--=============================================================================
-------------------------------------------------------------------------------
--                                                                        OCAML
--=============================================================================
-- Loaded when an OCaml file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- LSPCONFIG
-- NOTE: set ocamllsp the default lsp server for OCaml

require("plugins.lspconfig").distinct_setup("ocaml", function()
  -- Install ocamllsp, make sure it is in path

  require("lspconfig").ocamllsp.setup {
    capabilities = require("plugins.cmp").default_capabilities(),
    root_dir = require "util.root",
  }

  vim.fn.execute("LspStart", true)
end)

--------------------------------------------------------------------- FORMATTER
-- NOTE: set ocamlformat as the default formatter for OCaml

require("plugins.formatter").distinct_setup("ocaml", {
  -- opam install ocamlformat
  -- run eval $(opam config env) before ocamlformat if ocamlformat not found
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
})

----------------------------------------------------------------------- ACTIONS
-- NOTE: set default actions

require("plugins.actions").distinct_setup("ocaml", {
  actions = {
    -- Compile and run current ocaml file with ocamlopt
    run_current_ocaml_file = function()
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
})
