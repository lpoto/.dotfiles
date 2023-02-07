--=============================================================================
-------------------------------------------------------------------------------
--                                                                     GITSIGNS
--=============================================================================
-- https://github.com/lewis6991/gitsigns.nvim
-- https://github.com/samjswill/nvim-unception
--[[___________________________________________________________________________

Git decorators.
Show the current line's git blame with a 700ms delay.

Keymaps:
   - <leader>gd: Open diff view
   - <leader>gs: Stage current buffer
   - <leader>gh: Stage hunk
   - <leader>gu: Unstage current buffer
   - <leader>gr: Reset current buffer

------------------------------------------------------------------------------]]
local M = {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre" },
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

      vim.keymap.set("n", "<leader>gd", gs.diffthis, opts)
      vim.keymap.set("n", "<leader>gs", gs.stage_buffer, opts)
      vim.keymap.set("n", "<leader>gh", gs.stage_hunk, opts)
      vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, opts)
      vim.keymap.set("n", "<leader>gr", gs.reset_buffer, opts)
    end,
  }
  vim.api.nvim_create_autocmd("User", {
    pattern = "UnceptionEditRequestReceived",
    callback = function()
      vim.schedule(function()
        if vim.bo.buftype ~= "" or vim.bo.filetype:match "^git" then
          vim.bo.bufhidden = "wipe"
          vim.bo.swapfile = false
        end
      end)
    end,
  })
end

return M
