--=============================================================================
--                                    https://github.com/zbirenbaum/copilot.lua
--=============================================================================

return {
  "zbirenbaum/copilot.lua",
  commit = "0f2fd38",
  event = { "BufRead", "BufNewFile" },
  dependencies = {
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      commit = "468871c",
      cmd = "CopilotChat",
      opts = {}
    },
    {
      "nvim-lua/plenary.nvim",
      commit = "b9fd522",
    },
    {
      "fang2hou/blink-copilot",
      commit = "41e91a6",
      opts = {
        debounce = 200,
      }
    },
  },
  config = function()
    local copilot = require "copilot"
    copilot.setup {
      suggestion = { enabled = false },
      panel = { enabled = false },
    }
    local has_cmp, cmp = pcall(require, "blink.cmp")
    if has_cmp then
      -- Add Copilot as a source to blink.cmp, instead
      -- of having suggestiongs as virtual text,
      -- so that they are all in the same place

      ---@diagnostic disable-next-line
      table.insert(require "blink.cmp.config".sources.default, "copilot")
      cmp.add_source_provider("copilot", {
        score_offset = 90,
        min_keyword_length = 0,
        max_items = 3,
        name = "copilot",
        module = "blink-copilot",
        enabled = function() return true end,
        async = true,
        override = {
          get_trigger_characters = function(_)
            --- We allow empty string and space as trigger characters
            --- for Copilot, so that it can trigger
            --- on empty lines or when the user types a space.
            return { " ", "" }
          end
        }
      })
    end
  end,
}
