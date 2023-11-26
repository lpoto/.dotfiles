--=============================================================================
--                                         https://github.com/stevearc/oil.nvim
--[[===========================================================================

Keymaps:
 - "<leader>b"   - file browser relative to current file
 - "<leader>B"   - file browser relative to current working directory

 - "<C-q>"       - (in oil buffer) open quickfix list with all files in oil
                   buffer

-----------------------------------------------------------------------------]]

local M = {
  'stevearc/oil.nvim',
  cmd = 'Oil',
  keys = {
    { '<leader>b', function() vim.cmd 'Oil' end },
    { '<leader>B', function() vim.cmd('Oil ' .. vim.fn.getcwd()) end },
    { '<leader>N', function() vim.cmd 'Oil' end },
    { '<C-n>',     function() vim.cmd 'Oil' end },
  }
}
local util = {}

M.opts = {
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
    ['<C-q>'] = function() return util.oil_entries_to_quickfix() end
  },
}

function M.init()
  if util.is_starting_screen() then
    vim.cmd(
      'Oil ' ..
      (vim.fn.argc() == 1 and vim.fn.argv(0) or vim.fn.getcwd())
    )
  end
end

function util.is_starting_screen()
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

function util.oil_entries_to_quickfix()
  if vim.bo.filetype ~= 'oil' then return end
  local oil = require 'oil'
  local dir = oil.get_current_dir()

  local entries = {}
  for i = 1, vim.fn.line '$' do
    local entry = oil.get_entry_on_line(0, i)
    if entry and entry.type == 'file' then
      table.insert(entries, { filename = dir .. entry.name })
    end
  end
  if #entries == 0 then return end

  vim.fn.setqflist(entries)
  return vim.cmd.copen()
end

return M
