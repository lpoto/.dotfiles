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
  cmd = { "NullLsInfo", "NullLsLog" },
}

function M.init()
  vim.keymap.set("n", "<leader>f", function()
    require("plugins.null-ls").format()
  end)
end

function M.config()
  local null_ls = require "null-ls"

  null_ls.setup()
end

function M.format()
  local ok, e = pcall(function()
    vim.lsp.buf.format {
      timeout_ms = 10000,
      async = false,
    }
  end)
  if not ok and type(e) == "string" then
    vim.notify(e, vim.log.levels.WARN, {
      title = "Format",
    })
  end
end

---@param source string: Name of the builting formatting source
---@param filetype string?: Current filetype will be used when not provided
function M.register_formatter(source, filetype)
  M.register_builtin_source("formatting", source, filetype or vim.bo.filetype)
end

---@param source string: Name of the builting diagnostics source
---@param filetype string?: Current filetype will be used when not provided
function M.register_linter(source, filetype)
  M.register_builtin_source(
    "diagnostics",
    source,
    filetype or vim.bo.filetype
  )
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
