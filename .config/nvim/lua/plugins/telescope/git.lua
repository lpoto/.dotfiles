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

local M = {
  theme = "ivy",
}

local wrap_opts

function M.init()
  vim.keymap.set("n", "<leader>gl", M.git_commits, {})
  vim.keymap.set("n", "<leader>gb", M.git_branches, {})
  vim.keymap.set("n", "<leader>gg", M.git_status, {})
  vim.keymap.set("n", "<leader>gf", M.git_files, {})
  vim.keymap.set("n", "<leader>gS", M.git_stash, {})
end

function M.git_commits(opts)
  local telescope = require "telescope.builtin"

  opts = wrap_opts(opts)
  telescope.git_commits(opts)
end

function M.git_branches(opts)
  local telescope = require "telescope.builtin"

  opts = wrap_opts(opts)
  telescope.git_branches(opts)
end

function M.git_files(opts)
  local telescope = require "telescope.builtin"

  opts = wrap_opts(opts)
  telescope.git_files(opts)
end

function M.git_stash(opts)
  local telescope = require "telescope.builtin"

  opts = wrap_opts(opts)
  telescope.git_stash(opts)
end

local attach_git_status_mappings
function M.git_status(opts)
  local telescope = require "telescope.builtin"
  opts = wrap_opts(opts)
  opts.attach_mappings = attach_git_status_mappings
  telescope.git_status(opts)
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

wrap_opts = function(opts)
  opts = vim.tbl_extend(
    "force",
    require("telescope.themes")["get_" .. M.theme](),
    opts or {}
  )
  if not opts.selection_strategy then
    opts.selection_strategy = "row"
  end
  return opts
end

return M
