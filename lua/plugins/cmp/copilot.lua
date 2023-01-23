--=============================================================================
-------------------------------------------------------------------------------
--                                                               GITHUB COPILOT
--=============================================================================
-- https://github.com/zbirenbaum/copilot-cmp
-- https://github.com/zbirenbaum/copilot.lua
--_____________________________________________________________________________
--[[
Add github copilot as a cmp source
]]

local M = {
  "zbirenbaum/copilot-cmp",
  dependencies = {
    "zbirenbaum/copilot.lua",
  },
}

function M.config()
  require("copilot_cmp").setup {
    method = "getCompletionsCycling",
  }
  vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
  vim.defer_fn(function()
    local copilot = require "copilot"
    copilot.setup {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = false,
      },
    }
  end, 100)
end

return M
