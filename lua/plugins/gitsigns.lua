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

   - <leader>g (or :Git): Git status
          - <CR> to (un)stage selected file
          - <C-e> (or e in normal mode) to go to the selected file
   - <leader>gb: Git branches
          - <CR> to checkout the selected branch
          - <C-d> to delete the selected branch
          - <C-t> to track the selected branch
          - <C-r> to rebase the selected branch
          - <C-a> to create a new branch
          - <C-y> to merge the selected branch
   - <leader>gl Git log
          - <CR> to checkout the selected commit
          - <C-r>s to reset to the selected commit (soft)
          - <C-r>h to reset to the selected commit (hard)
          - <C-r>m to reset to the selected commit (mixed)
   - <leader>gS: Git stash
          - <CR> to apply the selected stash
   - <leader>gf: Git files
   - <leader>gc: Git commit
   - <leader>ga: Git commit ammend
   - <leader>gp: Git push

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
  vim.keymap.set("n", "<leader>g", M.git_status, {})
  vim.keymap.set("n", "<leader>gf", M.git_files, {})
  vim.keymap.set("n", "<leader>gS", M.git_stash, {})
  vim.keymap.set("n", "<leader>gc", M.git_commit, {})
  vim.keymap.set("n", "<leader>ga", M.git_commit_ammend, {})
  vim.keymap.set("n", "<leader>gp", M.git_push, {})

  vim.api.nvim_create_user_command("Git", M.git_status, {})
end

M.theme = "ivy"

local wrap_opts

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

function M.git_status(opts)
  local telescope = require "telescope.builtin"
  local actions = require "telescope.actions"

  opts = wrap_opts(opts)

  opts.attach_mappings = function(_, map)
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
  telescope.git_status(opts)
end

function M.git_push()
  if not vim.g.gitsigns_head or vim.g.gitsigns_head:len() == 0 then
    vim.notify("No current git HEAD", vim.log.levels.WARN, {
      title = "Git",
    })
    return
  end
  local cmd = "git push origin "
  local head = vim.fn.input(cmd, vim.g.gitsigns_head)
  if not head or head:len() == 0 then
    vim.notify("Invalid git command", vim.log.levels.WARN, {
      title = "Git",
    })
    return
  end
  cmd = cmd .. head
  require("plugins.unception").toggle_term(cmd)
end

function M.git_commit_ammend()
  return M.git_commit(true)
end

function M.git_commit(ammend)
  if not vim.g.gitsigns_head or vim.g.gitsigns_head:len() == 0 then
    vim.notify("No current git HEAD", vim.log.levels.WARN, {
      title = "Git",
    })
    return
  end
  local cmd = "git commit "
  if ammend then
    cmd = cmd .. "--amend"
  else
    cmd = cmd .. "-a"
  end
  require("plugins.unception").toggle_term(cmd)
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
