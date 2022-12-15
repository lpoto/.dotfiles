--=============================================================================
-------------------------------------------------------------------------------
--                                                                        OCAML
--=============================================================================
-- Loaded when an OCaml file is oppened.
--_____________________________________________________________________________

require("filetype")
  .new({
    copilot = true,
    -- opam install ocaml-lsp-server
    lsp_server = "ocamllsp",
    -- opam install ocamlformat
    formatter = function()
      return {
        exe = "eval $(opam config env) && ocamlformat",
        args = {
          "--enable-outside-detected-project",
          vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)),
        },
        stdin = true,
      }
    end,
    actions = {
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
  })
  :load()
