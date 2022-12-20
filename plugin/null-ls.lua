--=============================================================================
-------------------------------------------------------------------------------
--                                                                 NULL-LS.NVIM
--=============================================================================
-- https://github.com/jose-elias-alvarez/null-ls.nvim
--_____________________________________________________________________________

--[[
Injects lsp diagnostics, code actions, formatting,...

Keymaps:
  - <leader>f  - Format current file and save

Commands:
  - :NullLsInfo - Show information about the current null-ls session
  - :NullLsLog  - Open the log file
--]]

local mapper = require "mapper"

local plugin = require("plugin").new {
  "jose-elias-alvarez/null-ls.nvim",
  as = "null-ls",
  keys = "<leader>f",
  cmd = "NullLsInfo",
  module = "null-ls",
  config = function()
    local null_ls = require "null-ls"
    null_ls.setup()
    mapper.map(
      "n",
      "<leader>f",
      "<cmd>lua require('plugin').get('null-ls'):run('format')<CR>"
    )
  end,
}

-- format with "<leader>f""
plugin:action("format", function()
  vim.lsp.buf.format {
    timeout_ms = 10000,
    async = false,
  }
  vim.api.nvim_exec("w", true)
end)
