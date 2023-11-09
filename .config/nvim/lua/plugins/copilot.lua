--=============================================================================
-------------------------------------------------------------------------------
--  GITHUB COPILOT                                                  COPILOT.LUA
--[[===========================================================================
https://github.com/zbirenbaum/copilot.lua

-----------------------------------------------------------------------------]]

local M = {
  'zbirenbaum/copilot.lua',
  event = { 'BufRead', 'BufNewFile' },
  cmd = 'Copilot',
}

function M.config()
  vim.defer_fn(function()
    local ok, copilot = pcall(require, 'copilot')
    if not ok then return end
    copilot.setup {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          -- NOTE: accept is mapped to <CR> in
          -- the cmp.lua plugin config.
          accept = false,
          next = '<C-k>',
          prev = '<C-j>',
        },
      },
      filetypes = {
        ['*'] = true,
      },
      server_opts_overrides = {
        on_attach = function(c)
          c.server_capabilities.documentFormattingProvider = false
        end
      }
    }
  end, 250)
end

return M
