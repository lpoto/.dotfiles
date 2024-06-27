--=============================================================================
--                                    https://github.com/zbirenbaum/copilot.lua
--[[===========================================================================

Github Copilot

NOTE: Registers the copilot as a cmp source

-----------------------------------------------------------------------------]]

local M = {
  event = { "BufRead", "BufNewFile" },
  "zbirenbaum/copilot.lua",
  dependencies = {
    "JosefLitos/cmp-copilot",
    { "CopilotC-Nvim/CopilotChat.nvim", branch = "canary" }
  }
}

function M.config()
  vim.defer_fn(function()
    local copilot = require "copilot"
    copilot.setup {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = false,
      },
      server_opts_overrides = {
        on_attach = function(c)
          c.server_capabilities.documentFormattingProvider = false
        end,
      },
    }
    require "CopilotChat".setup()


    local ok, cmp = pcall(require, "cmp")
    if ok then
      require "cmp_copilot".setup()
      local cmp_config = cmp.get_config()
      local sources = cmp_config.sources or {}
      for _, v in ipairs(sources) do
        if v.name == "copilot" then
          return
        end
      end
      table.insert(sources,
        {
          name = "copilot",
          keyword_length = 0,
          priority = 9,
          max_item_count = 1,
        })
      cmp_config.sources = sources
    end
  end, 100)
end

return M;
