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
   - <leader>gs: Stage current buffer
   - <leader>gh: Stage hunk
   - <leader>gu: Unstage current buffer
   - <leader>gr: Reset current buffer
   - <leader>gp: Preview diff hunk in a popup
   - <leader>gd: Open diff view

   - <leader>gg (or :Git): Git status
          - <Tab> to stage selected file
          - <CR> to go to the selected file
   - <leader>gb: Git branches (see :h telescope.builtin.git_branches)
          - <CR> to checkout the selected branch
          - <C-d> to delete the selected branch
          - ... see :h telescope.builtin.git_branches
   - <leader>gl: Git commits (see :h telescope.builtin.git_commits)
          - <CR> to checkout the selected commit
          - ... see :h telescope.builtin.git_branches
   - <leader>gS: Git stash (see :h telescope.builtin.git_stash)
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
  vim.keymap.set("n", "<leader>gb", M.git_branches, {})
  vim.keymap.set("n", "<leader>gg", M.git_status, {})
  vim.keymap.set("n", "<leader>gf", M.git_files, {})

  vim.api.nvim_create_user_command("Git", M.git_status, {})
end

function M.git_commits(theme)
  local telescope = require "telescope.builtin"
  theme = theme or require("telescope.themes").get_ivy()
  telescope.git_commits(theme)
end

function M.git_branches(theme)
  local telescope = require "telescope.builtin"
  theme = theme or require("telescope.themes").get_ivy()
  telescope.git_branches(theme)
end

function M.git_files(theme)
  local telescope = require "telescope.builtin"
  theme = theme or require("telescope.themes").get_ivy()
  telescope.git_files(theme)
end

function M.git_status(theme)
  local telescope = require "telescope.builtin"
  local actions = require "telescope.actions"

  local opts = theme or require("telescope.themes").get_ivy()

  opts.attach_mappings = function(prompt_bufnr, map)
    map("i", "<Tab>", function()
      vim.cmd "normal k"
    end)
    map("n", "<Tab>", function()
      vim.cmd "normal k"
    end)
    map("n", "s", function()
      actions.git_staging_toggle(prompt_bufnr)
    end)
    map({ "n", "i" }, "<C-s>", function()
      actions.git_staging_toggle(prompt_bufnr)
    end)
    return true
  end
  opts.git_icons = {
    changed = ".",
  }
  telescope.git_status(opts)
end

return M
