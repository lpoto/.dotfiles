--=============================================================================
-------------------------------------------------------------------------------
--                                                                TELESCOPE GIT
--[[___________________________________________________________________________

Keymaps
   - <leader>gg Git status
      see :h telescope.builtin.git_status
   - <leader>gb: Git branches
      see :h telescope.builtin.git_branches
   - <leader>gl Git log
      see :h telescope.builtin.git_commits
   - <leader>gS: Git stash
          - <CR> to apply the selected stash
-----------------------------------------------------------------------------]]
local M = {}

local attach_git_status_mappings

function M.init()
  local telescope = require "telescope"
  local builtin = require "telescope.builtin"

  vim.keymap.set("n", "<leader>gl", builtin.git_commits, {})
  vim.keymap.set("n", "<leader>gb", builtin.git_branches, {})
  vim.keymap.set("n", "<leader>gg", builtin.git_status, {})
  vim.keymap.set("n", "<leader>gf", builtin.git_files, {})
  vim.keymap.set("n", "<leader>gS", builtin.git_stash, {})

  telescope.setup {
    pickers = {
      git_status = {
        theme = "ivy",
        initial_mode = "normal",
        attach_mappings = attach_git_status_mappings,
        selection_strategy = "row",
      },
      git_files = {
        theme = "ivy",
      },
      git_branches = {
        theme = "ivy",
        initial_mode = "normal",
      },
      git_commits = {
        theme = "ivy",
        initial_mode = "normal",
      },
      git_stash = {
        theme = "ivy",
        initial_mode = "normal",
      },
    },
  }
end

function attach_git_status_mappings(_, map)
  local actions = require "telescope.actions"
  actions.select_default:replace(actions.git_staging_toggle)
  map("n", "e", actions.file_edit)
  map("i", "<C-e>", actions.file_edit)
  map("i", "<Tab>", actions.move_selection_next)
  map("i", "<Tab>", actions.move_selection_next)
  map("n", "<Tab>", actions.move_selection_next)
  map("i", "<S-Tab>", actions.move_selection_previous)
  map("n", "<S-Tab>", actions.move_selection_previous)
  map("n", "s", actions.git_staging_toggle)
  map("i", "<C-s>", actions.git_staging_toggle)
  map("n", "<C-s>", actions.git_staging_toggle)
  return true
end

return M
