--=============================================================================
-------------------------------------------------------------------------------
--                                                                         HTML
--=============================================================================
-- Loaded when a html file is oppened.
--_____________________________________________________________________________

require("filetype")
  .new({
    always = function()
      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.opt.shiftwidth = 2
    end,
    copilot = true,
    -- npm install -g prettier
    formatter = function()
      return {
        exe = "prettier",
        args = {
          vim.fn.expand "%:p",
        },
        stdin = true,
      }
    end,
  })
  :load()
