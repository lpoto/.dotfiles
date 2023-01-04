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
   - <leader>gb: Toggle blame line (on by default)
   - <leader>gs: Stage current buffer
   - <leader>gu: Unstage current buffer
   - <leader>gr: Reset current buffer
   - <leader>gp: Preview diff hunk in a popup
   - <leader>gd: Open diff view
   - <leader>gl: Show git log
   - <leader>gi: Show git status
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

      vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, opts)
      vim.keymap.set("n", "<leader>gp", gs.preview_hunk, opts)
      vim.keymap.set("n", "<leader>gd", gs.diffthis, opts)
      vim.keymap.set("n", "<leader>gs", gs.stage_buffer, opts)
      vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, opts)
      vim.keymap.set("n", "<leader>gr", gs.reset_buffer, opts)
    end,
  }
end

function M.init()
  vim.keymap.set("n", "<leader>gl", M.git_log, {})
  vim.keymap.set("n", "<leader>gi", M.git_status, {})
end

function M.git_log()
  local ok, e = pcall(vim.api.nvim_exec, "vertical new", true)
  if ok == false then
    vim.notify(e, vim.log.levels.ERROR)
    return
  end
  ok, e = pcall(
    vim.fn.termopen,
    "git log --graph --color=always --decorate --pretty=oneline --abbrev-commit",
    {
      detach = false,
    }
  )
  if ok == false then
    vim.notify(e, vim.log.levels.ERROR)
  end
end

function M.git_status()
  local ok, e = pcall(vim.api.nvim_exec, "vertical new", true)
  if ok == false then
    vim.notify(e, vim.log.levels.ERROR)
    return
  end
  ok, e = pcall(vim.fn.termopen, "git status", {
    detach = false,
  })
  if ok == false then
    vim.notify(e, vim.log.levels.ERROR)
  end
end

return M
