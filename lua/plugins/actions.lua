--=============================================================================
-------------------------------------------------------------------------------
--                                                                 ACTIONS.NVIM
--=============================================================================
-- https://github.com/lpoto/actions.nvim
--_____________________________________________________________________________

local actions = require("util.packer_wrapper").get "actions"

---Setup the actions plugin, use :Actions command
---to open the actions window, use <leader>e to toggle last output
---Use Ctrl-c to kill the action running in the oppened output window.
actions:config(function()
  local mapper = require "util.mapper"
  require("actions").setup {}

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

  mapper.map(
    "n",
    "<leader>e",
    "<CMD>lua require('actions').toggle_last_output()<CR>"
  )
end)
