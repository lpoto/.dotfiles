--=============================================================================
-------------------------------------------------------------------------------
--                                                                         HTML
--=============================================================================
-- Loaded when a html file is oppened.
--_____________________________________________________________________________

require("filetype")
  .new({
    buffer_options = {
      tabstop = 2,
      softtabstop = 2,
      shiftwidth = 2,
    },
    copilot = true,
    -- npm install -g prettier
    formatter = function()
      return {
        exe = "prettier",
        args = {
          vim.api.nvim_buf_get_name(0),
        },
        stdin = true,
      }
    end,
  })
  :load()
