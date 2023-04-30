--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-LSPCONFIG
--=============================================================================
-- https://github.com/neovim/nvim-lspconfig
--_____________________________________________________________________________

--[[
Configuration for the built-in LSP client.
see github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
for server configurations.
Lsp is then enabled with ':LspStart' (this is usually done automatically for
filetypes in ftplguin/)


Keymaps:
  - "gd"    - jump to the definition of the symbol under cursor
  - "K" -  Show the definition of symbol under the cursor
  - "<C-d>" -  Show the diagnostics of the line under the cursor
--]]
local M = {
  "neovim/nvim-lspconfig",
  cmd = { "LspStart", "LspInfo" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
}

function M.init()
  vim.keymap.set("n", "K", function()
    vim.lsp.buf.hover()
  end)
  vim.keymap.set("n", "<C-d>", function()
    vim.diagnostic.open_float()
  end)
  vim.keymap.set("n", "gd", function()
    vim.lsp.buf.definition()
  end)
end

---Show definition of symbol under cursor, unless
---there are any diagnostics on the current line.
---Then display those diagnostics instead.
function M.show_definition()
  if vim.diagnostic.open_float() then
    return
  end
  vim.lsp.buf.hover()
end

---Start the provided language server, if no opts
---are provided, {} will be used.
---opts.capabilities will be automatically set to
---cmp's default capabilities if not found.
---@param server string: Name of the server to start
---@param opts table?: Optional server configuration
function M.start_language_server(server, opts)
  local lspconfig = require "lspconfig"
  opts = opts or {}

  if opts.capabilities == nil then
    opts.capabilities = require("cmp_nvim_lsp").default_capabilities()
  elseif opts.capabilities == false then
    opts.capabilities = nil
  end

  if lspconfig[server] == nil then
    vim.notify("LSP server not found: " .. server, vim.log.levels.WARN)
    return
  end

  local lsp = lspconfig[server]
  if lsp == nil then
    vim.notify("LSP server not found: " .. server, vim.log.levels.WARN)
    return
  end

  lsp.setup(opts)

  local ok, e = pcall(vim.fn.execute, "LspStart", true)
  if ok == false then
    vim.notify("Failed to start LSP: " .. e, vim.log.levels.WARN)
  end
end

return M
