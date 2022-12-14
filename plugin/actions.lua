--=============================================================================
-------------------------------------------------------------------------------
--                                                                 ACTIONS.NVIM
--=============================================================================
-- https://github.com/lpoto/actions.nvim
--_____________________________________________________________________________

require("plugin").new {
  "lpoto/actions.nvim",
  as = "actions",
  cmd = "Actions", -- Open available actions window
  config = function(actions)
    actions.setup {}

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

    vim.api.nvim_set_keymap(
      "n",
      "<leader>e",
      "<CMD>lua require('actions').toggle_last_output()<CR>",
      { noremap = true }
    )
  end,
}
