--=============================================================================
-------------------------------------------------------------------------------
--                                                      TELESCOPE-SESSIONS.NVIM
--[[===========================================================================
https://github.com/lpotot/telescope-sessions.nvim

Commands:
  - :Sessions - Display all available sessions
              (<CR> - load session, <C-d> - delete session)

Keymaps:
  - <leader>s - same as :Sessions (<CR> in the starting screen)

-----------------------------------------------------------------------------]]

local M = {
  'lpoto/telescope-sessions.nvim',
  event = 'VimLeavePre',
  cmd = 'Sessions',
}

function M.init()
  vim.keymap.set('n', '<leader>s', function()
    require 'telescope'.extensions.sessions.sessions()
  end)
  if vim.bo.filetype == '' and
    vim.bo.buftype == '' and
    vim.api.nvim_buf_get_name(0) == '' and
    vim.api.nvim_get_current_line() == ''
  then
    vim.keymap.set('n', '<CR>', function()
      require 'telescope'.extensions.sessions.sessions()
    end, { buffer = 0 })
  end
end

function M.config()
  vim.api.nvim_create_user_command(
    'Sessions',
    function() require 'telescope'.extensions.sessions.sessions() end,
    {}
  )
  local ok, telescope = pcall(require, 'telescope')
  if not ok then return end
  telescope.setup {
    extensions = {
      sessions = {
        layout_config = {
          width = 130,
        },
      },
    },
  }
  telescope.load_extension 'sessions'
end

return M
