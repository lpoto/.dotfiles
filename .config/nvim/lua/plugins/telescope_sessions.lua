--=============================================================================
-------------------------------------------------------------------------------
--                                                      TELESCOPE-SESSIONS.NVIM
--[[===========================================================================
https://github.com/lpoto/telescope-sessions.nvim

Commands:
  - :Sessions - Display all available sessions
              (<CR> - load session, <C-d> - delete session)

Keymaps:
  - <leader>s - same as :Sessions

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
    if require 'telescope'.extensions.sessions.actions
      .get_available_sessions_count() > 0 then
      vim.schedule(function()
        require 'telescope'.extensions.sessions.sessions {
          initial_mode = 'normal',
        }
      end)
    else
      vim.notify('No sessions available', vim.log.levels.INFO)
    end
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
