--=============================================================================
-------------------------------------------------------------------------------
--                                                                 ACTIONS.NVIM
--=============================================================================
-- https://github.com/lpoto/actions.nvim
--_____________________________________________________________________________

--[[
A plugin for running asynchronous actions.
This uses telescope prompt window, if telescope is available.

commands:
  - :Actions  - display all available actions
--]]

require("plugin").new {
  "lpoto/actions.nvim",
  as = "actions",
  cmd = "Actions", -- Open available actions window
  config = function()
    local actions = require "actions"
    local mapper = require "mapper"

    actions.setup {}

    mapper.command("Actions", function()
      pcall(require, "telescope")
      if package.loaded["telescope"] then
        require("actions.telescope").available_actions(
          require("telescope.themes").get_ivy()
        )
      else
        require("actions").available_actions()
      end
    end)

    -- NOTE: toggle the output of the latest action

    mapper.map(
      "n",
      "<leader>e",
      "<CMD>lua require('actions').toggle_last_output()<CR>"
    )
  end,
}
