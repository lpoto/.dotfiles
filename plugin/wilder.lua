--=============================================================================
-------------------------------------------------------------------------------
--                                                                  WILDER.NVIM
--=============================================================================
-- https://github.com/gelguy/wilder.nvim
--_____________________________________________________________________________

--[[
Updated wildmenu in cmdline.
Displays completion results in the statusline when ussing :, / or ?.
--]]

require("plugin").new {
  "gelguy/wilder.nvim",
  as = "wilder",
  event = "CmdlineEnter",
  config = function()
    local wilder = require "wilder"
    wilder.setup {
      modes = { ":", "/", "?" },
      next_key = "<Tab>",
      previous_key = "<S-Tab>",
    }
    wilder.set_option("pipeline", {
      wilder.branch(wilder.cmdline_pipeline(), wilder.search_pipeline()),
    })
    wilder.set_option(
      "renderer",
      wilder.wildmenu_renderer {
        highlighter = wilder.basic_highlighter(),
      }
    )
  end,
}
