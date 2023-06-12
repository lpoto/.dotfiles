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

local set_accept_keymap

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
      set_accept_keymap()
    end)
  end, 100)
end

--- Allow accepting copilot suggestions with <CR>,
--- if the suggestion window is visible.
--- Otherwise <CR> works as usual.
function set_accept_keymap()
  Util.log():info "set_accept_keymap"
  vim.keymap.set("i", "<CR>", function()
    return Util.require("copilot.suggestion", function(suggestion)
      if suggestion.is_visible() then
        vim.defer_fn(function()
          suggestion.accept()
        end, 5)
        return true
      end
      return "<CR>"
    end) or "<CR>"
  end, { expr = true })
end

return M
