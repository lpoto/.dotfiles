--=============================================================================
--                                    https://github.com/zbirenbaum/copilot.lua
--=============================================================================

local M = {
  "zbirenbaum/copilot.lua",
  dependencies = {
    "CopilotC-Nvim/CopilotChat.nvim",
  },
  event = { "BufRead", "BufNewFile" },
  cmd = { "Copilot", "CopilotChat" },
}

function M.config()
  vim.defer_fn(function()
    require("copilot").setup {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          -- NOTE: accept is mapped in cmp.lua plugin config.
          accept = false,
          next = "<C-k>",
          prev = "<C-j>",
        },
      },
      server_opts_overrides = {
        on_attach = function(c)
          c.server_capabilities.documentFormattingProvider = false
        end,
      },
    }
    require("CopilotChat").setup()
  end, 250)
end

return M
