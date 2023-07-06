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
      copilot.setup({
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            -- NOTE: accept is mapped to <CR> in
            -- the cmp.lua plugin config.
            accept = false,
            dismiss = "<C-x>",
            next = "<C-k>",
            prev = "<C-j>",
          },
        },
        filetypes = {
          ["*"] = true,
        },
      })
    end)
  end, 250)
end

return M
