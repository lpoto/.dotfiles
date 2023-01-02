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

local M = {
  "jose-elias-alvarez/null-ls.nvim",
  keys = "<leader>f",
  cmd = { "NullLsInfo", "NullLsLog" },
}

function M.config()
  local null_ls = require "null-ls"

  null_ls.setup()

  vim.api.nvim_set_keymap(
    "n",
    "<leader>f",
    "<cmd>lua require('plugins.null-ls').format()<CR>",
    { noremap = true }
  )
end

-- format with "<leader>f""
function M.format()
  vim.lsp.buf.format {
    timeout_ms = 10000,
    async = false,
  }
  vim.api.nvim_exec("w", true)
end

---@param source string
---@param filetype string
function M.register_builtin_source(type, source, filetype)
  local null_ls = require "null-ls"
  null_ls.register {
    filetypes = { filetype },
    sources = { null_ls.builtins[type][source] },
  }
end

return M
