--=============================================================================
-------------------------------------------------------------------------------
--                                                                     GITSIGNS
--[[___________________________________________________________________________
https://github.com/lewis6991/gitsigns.nvim

-- Show git blames of current line, allow staging hunks and buffers...

-----------------------------------------------------------------------------]]
local M = {
  "lewis6991/gitsigns.nvim",
  event = { "BufRead", "BufNewFile" },
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
  vim.defer_fn(function()
    vim.api.nvim_exec_autocmds("User", {
      pattern = "GitsignsReady",
    })
  end, 100)
end

return M
