--=============================================================================
-------------------------------------------------------------------------------
--                                                               GITHUB COPILOT
--=============================================================================
-- https://github.com/github/copilot.vim
--_____________________________________________________________________________

--[[
A github copilot plugin. Uses the github copilot API to generate code.

Keymaps:
   - <C-Space> - Select the next suggestion
   - <C-k>     - show the next suggestion
   - <C-j>     - show the previous suggstion

Configure copilot with :Copilot setup
--]]

local M = {
  "zbirenbaum/copilot.lua",
  event = "VeryLazy",
}

function M.config()
  vim.defer_fn(function()
    local copilot = require "copilot"
    copilot.setup {
      panel = {
        enabled = true,
        keymap = {
          accept = "<CR>",
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 100,
      },
    }
  end, 100)
end

return M
