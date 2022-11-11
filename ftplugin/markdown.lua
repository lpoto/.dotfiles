--=============================================================================
-------------------------------------------------------------------------------
--                                                                     MARKDOWN
--=============================================================================
-- Loaded when a markdown file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- FORMATTER
-- NOTE: set prettier as default markdown formatter

require("plugins.formatter").distinct_setup("markdown", {
  -- npm install -g prettier

  filetype = {
    markdown = {
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
