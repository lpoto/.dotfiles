--=============================================================================
-------------------------------------------------------------------------------
--                                                               GITHUB COPILOT
--=============================================================================
-- https://github.com/zbirenbaum/copilot.lua
--_____________________________________________________________________________

local M = {
  "zbirenbaum/copilot.lua",
  event = "User RealInsertEnter",
}

function M.config()
  vim.defer_fn(function()
    local copilot = require "copilot"

    copilot.setup {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<C-Space>",
          next = "<C-k>",
          prev = "<C-j>",
        },
      },
    }
  end, 100)
end

function M.show_prev_expression_func(key)
  if not package.loaded["copilot"] then
    return key
  end
  local suggestion = require "copilot.suggestion"
  if not suggestion.is_visible() then
    return key
  end
  vim.schedule(function()
    suggestion.prev()
  end)
end

function M.accept_suggestion_expression_func(key)
  if not package.loaded["copilot"] then
    return key
  end
  local suggestion = require "copilot.suggestion"
  if not suggestion.is_visible() then
    return key
  end
  vim.schedule(function()
    suggestion.accept()
  end)
end

function M.dismiss_suggestion_expression_func(key)
  if not package.loaded["copilot"] then
    return key
  end
  local suggestion = require "copilot.suggestion"
  if not suggestion.is_visible() then
    return key
  end
  vim.schedule(function()
    suggestion.dismiss()
  end)
end

return M
