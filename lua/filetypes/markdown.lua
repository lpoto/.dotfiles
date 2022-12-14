--=============================================================================
-------------------------------------------------------------------------------
--                                                                     MARKDOWN
--=============================================================================
-- Loaded when a markdown file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- FORMATTER
--github.com/mhartington/formatter.nvim/blob/master/lua/formatter/filetypes/markdown.lua

local formatter = require("util.packer.wrapper").get "formatter"

-- NOTE: set prettier as default markdown formatter
formatter:config(function()
  --[[
      npm install -g prettier
  ]]
  require("formatter").setup {
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
  }
end, "markdown")
