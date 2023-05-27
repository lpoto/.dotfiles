--=============================================================================
-------------------------------------------------------------------------------
--                                                                     GITSIGNS
--[[___________________________________________________________________________
https://github.com/lewis6991/gitsigns.nvim

Show git blames of current line, allow staging hunks and buffers...
-----------------------------------------------------------------------------]]
local M = {
  "lewis6991/gitsigns.nvim",
  event = { "BufRead", "BufNewFile" },
}

function M.config()
  Util.require("gitsigns", function(gitsigns)
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
        local opts = { buffer = bufnr }

        vim.keymap.set("n", "<leader>gd", gitsigns.diffthis, opts)
        vim.keymap.set("n", "<leader>gs", gitsigns.stage_buffer, opts)
        vim.keymap.set("n", "<leader>gh", gitsigns.stage_hunk, opts)
        vim.keymap.set("n", "<leader>gu", gitsigns.undo_stage_hunk, opts)
        vim.keymap.set("n", "<leader>gr", gitsigns.reset_buffer, opts)
      end,
    }
    vim.defer_fn(function()
      vim.api.nvim_exec_autocmds("User", {
        pattern = "GitsignsReady",
      })
    end, 100)
  end)
end

return M
