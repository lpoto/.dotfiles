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
          dismiss = "<C-x>",
        },
      },
    }
    M.keymap()
  end, 100)
end

--- When copilot suggestion is visible and cmp popup is not visible,
--- <Tab> will accept the suggestion.
function M.keymap()
  vim.keymap.set("i", "<Tab>", function()
    if
      (package.loaded["cmp"] and require("cmp").visible())
      or not package.loaded["copilot"]
      or not require("copilot.suggestion").is_visible()
    then
      return "<Tab>"
    end
    vim.schedule(function()
      require("copilot.suggestion").accept()
    end)
  end, { expr = true })
end

return M
