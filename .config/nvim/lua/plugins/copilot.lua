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
    M.keymap()
  end, 100)
end

---Set up the copilot dismiss keymap. (<C-x>)
---If cmp popup is visible, it will be closed, otherwise
---the copilot suggestion will be dismissed and cmp reopened.
function M.keymap()
  vim.keymap.set("i", "<C-x>", function()
    local copilot_suggestion = require "copilot.suggestion"
    if package.loaded["cmp"] then
      local cmp = require "cmp"
      if cmp.visible() then
        cmp.close()
        return
      elseif copilot_suggestion.is_visible() then
        copilot_suggestion.dismiss()
      end
      cmp.complete()
    end
  end)
end

return M
