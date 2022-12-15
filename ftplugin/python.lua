--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PYTHON
--=============================================================================
-- Loaded when a python file is oppened.
--_____________________________________________________________________________

require("filetype")
  .new({
    copilot = true,
    -- pip install pylsp
    lsp_server = "pylsp",
    -- pip install flake8
    linter = "flake8",
    -- pip install autopep8
    formatter = function()
      return {
        exe = "python3 -m autopep8",
        args = {
          "--aggressive --aggressive --aggressive -",
        },
        stdin = true,
      }
    end,
    actions = {
      ["Run current Python file"] = function()
        return {
          filetypes = { "python" },
          steps = {
            { "python3", vim.fn.expand "%:p" },
          },
        }
      end,
    },
  })
  :load()
