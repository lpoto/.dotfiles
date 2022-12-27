--=============================================================================
-------------------------------------------------------------------------------
--                                                                         RUBY
--=============================================================================
-- Loaded when a ruby file is opened.
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

local filetype = require "config.filetype"

filetype.config {
  filetype = "ruby",
  priority = 0,
  copilot = true,
  language_server = "solargraph",
  formatter = "rubocop",
}

-- Configure actions
filetype.config {
  filetype = "ruby",
  priority = 0,
  actions = {
    ["Run current Ruby file"] = function()
      return {
        filetypes = { "ruby" },
        steps = {
          { "ruby", vim.api.nvim_buf_get_name(0) },
        },
      }
    end,
  },
}

filetype.load "ruby"
