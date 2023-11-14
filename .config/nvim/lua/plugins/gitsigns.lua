--=============================================================================
--                                  https://github.com/lewish6991/gitsigns.nvim
--=============================================================================

return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufRead', 'BufNewFile' },
  opts = {
    signcolumn = false,
    numhl = true,
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol',
      delay = 1000,
    },
    update_debounce = 250,
    on_attach = function(buf)
      local gitsigns = package.loaded.gitsigns
      local map = function(m, k, f) vim.keymap.set(m, k, f, { buffer = buf }) end
      map('n', '<leader>gs', gitsigns.stage_buffer)
      map('n', '<leader>gh', gitsigns.stage_hunk)
      map('n', '<leader>gu', gitsigns.undo_stage_hunk)
      map('n', '<leader>gr', gitsigns.reset_buffer)
    end,
  },
}
