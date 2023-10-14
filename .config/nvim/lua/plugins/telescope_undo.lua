--=============================================================================
-------------------------------------------------------------------------------
--                                                          TELESCOPE-UNDO.NVIM
--[[===========================================================================
https://github.com/debugloop/telescope-undo.nvim

View and search your undo tree

commands:
  - :Undo - show undo tree

keymaps:
  - "<leader>u" - show undo tree
-----------------------------------------------------------------------------]]

local M = {
  'debugloop/telescope-undo.nvim',
  cmd = 'Undo',
}

local function open_undo() require 'telescope'.extensions.undo.undo() end

M.keys = {
  { '<leader>u', open_undo, mode = 'n' },
}

function M.init() vim.api.nvim_create_user_command('Undo', open_undo, {}) end

function M.config() require 'telescope'.load_extension 'undo' end

return M
