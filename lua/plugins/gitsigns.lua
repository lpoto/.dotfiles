--=============================================================================
-------------------------------------------------------------------------------
--                                                                GITSIGNS.NVIM
--=============================================================================
-- https://github.com/lewis6991/gitsigns.nvim
--_____________________________________________________________________________

--[[
Git decorators.

Added lines's numbers are shown in green,
removed in red and modified in blue.

Show the current line's git blame with a 700ms delay.

Keymaps:
   - <leader>gd: Open diff view
   - <leader>gs: Stage current buffer
   - <leader>gh: Stage hunk
   - <leader>gu: Unstage current buffer
   - <leader>gr: Reset current buffer
   - <leader>gp: Preview diff hunk in a popup

   - <leader>gg (or :Git): Git status
          - <C-s> to stage selected file
          - <CR> to go to the selected file
   - <leader>gb: Git branches
          - <CR> to checkout the selected branch
          - <C-d> to delete the selected branch
          - <C-t> to track the selected branch
          - <C-r> to rebase the selected branch
          - <C-a> to create a new branch
          - <C-y> to merge the selected branch
   - <leader>gl (or <leader>gc): Git commits
          - <CR> to checkout the selected commit
          - <C-r>s to reset to the selected commit (soft)
          - <C-r>h to reset to the selected commit (hard)
          - <C-r>m to reset to the selected commit (mixed)
   - <leader>gS: Git stash
          - <CR> to apply the selected stash
   - <leader>gf: Git files

--]]

local M = {
  "lewis6991/gitsigns.nvim",
  event = { "BufNewFile", "BufReadPre" },
}

function M.config()
  local gitsigns = require "gitsigns"

  gitsigns.setup {
    signcolumn = false,
    numhl = true,
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 700,
    },
    on_attach = function(bufnr)
      local gs = require "gitsigns"
      local opts = { buffer = bufnr }

      vim.keymap.set("n", "<leader>gp", gs.preview_hunk, opts)
      vim.keymap.set("n", "<leader>gd", gs.diffthis, opts)
      vim.keymap.set("n", "<leader>gs", gs.stage_buffer, opts)
      vim.keymap.set("n", "<leader>gh", gs.stage_hunk, opts)
      vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, opts)
      vim.keymap.set("n", "<leader>gr", gs.reset_buffer, opts)
    end,
  }
end

function M.init()
  vim.keymap.set("n", "<leader>gl", M.git_commits, {})
  vim.keymap.set("n", "<leader>gc", M.git_commits, {})
  vim.keymap.set("n", "<leader>gb", M.git_branches, {})
  vim.keymap.set("n", "<leader>gg", M.git_status, {})
  vim.keymap.set("n", "<leader>gf", M.git_files, {})
  vim.keymap.set("n", "<leader>gS", M.git_stash, {})

  vim.api.nvim_create_user_command("Git", M.git_status, {})
end

function M.git_commits()
  local telescope = require "telescope.builtin"

  local theme = require("telescope.themes").get_ivy()

  theme.results_title = "<CR> - checkout, <C-r>s|h|m - reset soft|hard|mixed"
  theme.selection_strategy = "row"

  telescope.git_commits(theme)
end

function M.git_branches()
  local telescope = require "telescope.builtin"

  local theme = require("telescope.themes").get_ivy()

  theme.results_title = "<CR> - checkout, <C-d|t|r|a|y> - "
    .. "delete|track|rebase|create|merge"
  theme.selection_strategy = "row"

  telescope.git_branches(theme)
end

function M.git_files()
  local telescope = require "telescope.builtin"

  local theme = require("telescope.themes").get_ivy()

  theme.results_title = "<CR> - open file"
  theme.selection_strategy = "row"

  telescope.git_files(theme)
end

function M.git_stash()
  local telescope = require "telescope.builtin"

  local theme = require("telescope.themes").get_ivy()

  theme.results_title = "<CR> - apply stash"
  theme.selection_strategy = "row"

  telescope.git_stash(theme)
end

function M.git_status()
  local telescope = require "telescope.builtin"
  local actions = require "telescope.actions"

  local opts = require("telescope.themes").get_ivy()

  opts.results_title = "<C-s> - stage/unstage, <CR> - open file"
  opts.selection_strategy = "row"

  opts.attach_mappings = function(_, map)
    map("i", "<Tab>", actions.move_selection_next)
    map("n", "<Tab>", actions.move_selection_next)
    map("i", "<S-Tab>", actions.move_selection_previous)
    map("n", "<S-Tab>", actions.move_selection_previous)
    map("n", "s", actions.git_staging_toggle)
    map("i", "<C-s>", actions.git_staging_toggle)
    map("n", "<C-s>", actions.git_staging_toggle)
    return true
  end
  telescope.git_status(opts)
end

return M
