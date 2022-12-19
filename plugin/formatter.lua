--=============================================================================
-------------------------------------------------------------------------------
--                                                               FORMATTER.NVIM
--=============================================================================
-- https://github.com/mhartington/formatter.nvim
--_____________________________________________________________________________

--[[
A format runner for neovim.

See github.com/mhartington/formatter.nvim/tree/master/lua/formatter/filetypes
for configurations for specific filetypes.

Keymaps:
  - <leader>f - Format the current buffer
--]]

local plugin = require("plugin").new {
  "mhartington/formatter.nvim",
  as = "formatter",
  cmd = { "Format", "FormatWrite", "FormatLock", "FormatWriteLock" },
  keys = { "<leader>f" },
  config = function()
    local formatter = require "formatter"
    formatter.setup {
      logging = true,
      log_level = vim.log.levels.INFO,
      filetype = {
        ["*"] = {
          require("formatter.filetypes.any").remove_trailing_whitespace,
        },
      },
    }
  end,
}

-- format with "<leader>f""
plugin:config(function()
  local mapper = require "mapper"

  mapper.map("n", "<leader>f", "<cmd>FormatWriteLock<CR>")
end)