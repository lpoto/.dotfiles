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
  vim.keymap.set("n", "K", vim.lsp.buf.hover)
  vim.keymap.set("n", "<C-d>", vim.diagnostic.open_float)
  vim.keymap.set("n", "<leader>D", vim.diagnostic.open_float)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition)
end

---Start the provided language server, if no opts
---are provided, {} will be used.
---opts.capabilities will be automatically set to
---cmp's default capabilities if not found.
---@param server string: Name of the server to start
---@param opts table?: Optional server configuration
function M.start_language_server(server, opts)
  local log = require("config.util").logger("Start", server)
  local lspconfig = require "lspconfig"
  opts =
    vim.tbl_deep_extend("force", opts or {}, vim.g[server .. "_config"] or {})

  if opts.capabilities == nil then
    opts.capabilities = require("cmp_nvim_lsp").default_capabilities()
  elseif opts.capabilities == false then
    opts.capabilities = nil
  end

  if lspconfig[server] == nil then
    log:warn("LSP server not found: ", server)
    return
  end

  local lsp = lspconfig[server]
  if lsp == nil then
    log:warn("LSP server not found: ", server)
    return
  end

  lsp.setup(opts)

  local ok, e = pcall(vim.fn.execute, "LspStart", true)
  if ok == false then
    log:warn("Failed to start LSP", e)
  end
end

return M
