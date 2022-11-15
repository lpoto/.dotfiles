--=============================================================================
-------------------------------------------------------------------------------
--                                                                        XHTML
--=============================================================================
-- Loaded when a xhtml file is oppened.
--_____________________________________________________________________________

----------------------------------------------------------------------- OPTIONS
-- NOTE: set default tab width for xhtml

vim.opt.tabstop = 2 -- set the width of a tab to 2
vim.opt.softtabstop = 2 -- set the number of spaces that a tab counts for
vim.opt.shiftwidth = 2 -- number of spaces used for each step of indent

--------------------------------------------------------------------- FORMATTER
-- NOTE: set prettier as default xhtml formatter

require("plugins.formatter").distinct_setup("html", {
  -- npm install -g prettier

  filetype = {
    xhtml = {
      function()
        return {
          exe = "prettier",
          args = {
            vim.fn.expand "%:p",
          },
          stdin = true,
        }
      end,
    },
  },
})
