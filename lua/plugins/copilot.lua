--=============================================================================
-------------------------------------------------------------------------------
--                                                               GITHUB COPILOT
--[[===========================================================================
https://github.com/zbirenbaum/copilot.lua

-----------------------------------------------------------------------------]]
local M = {
  "zbirenbaum/copilot.lua",
  event = { "BufRead", "BufNewFile" },
  cmd = "Copilot",
}

function M.config()
  vim.defer_fn(function()
    Util.require("copilot", function(copilot)
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
            dismiss = "<C-z>",
          },
        },
        filetypes = {
          ["*"] = function()
            local ok, n = pcall(vim.fn.getfsize, vim.fn.expand "%")
            return ok and n < 50000
          end,
        },
      }
    end)
  end, 100)
end

return M
