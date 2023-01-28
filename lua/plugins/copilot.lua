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
  event = "User CmpLoaded",
  dependencies = {
    "zbirenbaum/copilot.lua",
  },
}

function M.config()
  vim.defer_fn(function()
    require("copilot_cmp").setup {
      method = "getCompletionsCycling",
    }
    vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
    local copilot = require "copilot"
    copilot.setup {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = false,
      },
    }
    M.attach_to_cmp()
  end, 100)
end

function M.attach_to_cmp()
  local cmp = require "cmp"

  local config = cmp.get_config()
  config.sources = config.sources or {}
  table.insert(config.sources, {
    name = "copilot",
    group_index = 2,
    keyword_length = 0,
  })
  config.sorting = config.sorting or {}
  config.sorting.priority_weight = 0
  config.sorting.comprators = {
    require("copilot_cmp.comparators").prioritize,
    require("copilot_cmp.comparators").score,
    unpack(config.sorting.comparators or {}),
  }
  config.formatting = config.formatting or {}
  table.insert(config.formatting, {
    format = require("copilot_cmp.format").remove_existing,
  })
end

return M
