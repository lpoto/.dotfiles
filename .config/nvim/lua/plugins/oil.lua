--=============================================================================
-------------------------------------------------------------------------------
--                                                                     OIL.NVIM
--[[===========================================================================
https://github.com/stevearc/oil.nvim

Keymaps:
 - "<leader>N"   - file browser relative to current file

-----------------------------------------------------------------------------]]
local M = {
  'stevearc/oil.nvim',
  cmd = 'Oil',
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    buf_options = {
      buflisted = false,
      bufhidden = 'wipe',
    },
    win_options = {
      number = false,
      relativenumber = false,
    },
    view_options = {
      show_hidden = true,
    },
    columns = {},
    keymaps = {
      ['<BS>'] = 'actions.parent',
      ['<leader>N'] = 'actions.open_cwd',
      ['<C-n>'] = 'actions.open_cwd',
    },
  },
  keys = {
    { '<leader>N', function() vim.cmd 'Oil' end, mode = 'n' },
    { '<C-n>',     function() vim.cmd 'Oil' end, mode = 'n' },
  }
}

local is_starting_screen
function M.init()
  if is_starting_screen() then
    vim.cmd(
      'Oil ' ..
      (vim.fn.argc() == 1 and vim.fn.argv(0) or vim.fn.getcwd())
    )
  end
end

function is_starting_screen()
  return (
      vim.fn.argc() == 0 or
      vim.fn.argc() == 1 and
      vim.fn.isdirectory(vim.fn.expand(vim.fn.argv(0) --[[@as string]])) == 1
    )
    and
    #vim.api.nvim_list_bufs() == 1 and
    vim.api.nvim_buf_line_count(0) == 0 and
    vim.api.nvim_get_option_value('buftype', { buf = 0 }) == '' and
    vim.api.nvim_get_option_value('filetype', { buf = 0 }) == ''
end

return M
