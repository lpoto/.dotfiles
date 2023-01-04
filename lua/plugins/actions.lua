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

local M = {
  "lpoto/actions.nvim",
  cmd = "Actions", -- Open available actions window
}

function M.config()
  local actions = require "actions"
  local actions_config = require "plugins.actions"

  actions.setup {
    actions = actions_config.actions,
  }
  actions_config.actions = nil

  vim.api.nvim_create_user_command("Actions", function()
    pcall(require, "telescope")
    if package.loaded["telescope"] then
      require("actions.telescope").available_actions(
        require("telescope.themes").get_ivy()
      )
    else
      require("actions").available_actions()
    end
  end, {})

  -- NOTE: toggle the output of the latest action

  vim.keymap.set("n", "<leader>e", function()
    require("actions").toggle_last_output()
  end)
end

---Adds the provided table of actions to the
---plugin's config. If the plugin is not yet loaded, this
---will run once it is loaded.
---
---@param actions table: A table of actions
function M.add_actions(actions)
  if package.loaded["actions"] ~= nil then
    require("actions").setup {
      actions = actions,
    }
    return
  end
  M.actions = M.actions or {}
  M.actions = vim.tbl_extend("force", M.actions, actions)
end

return M
