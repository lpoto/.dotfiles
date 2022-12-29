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
  - "K"     - show the documentation of the symbol under cursor,
                   or diagnostics if there are any.
  - "<C-k>" -  Show the definition of symbol under the cursor
  - "<C-d>" -  Show the diagnostics of the line under the cursor
--]]

local M = {
  "neovim/nvim-lspconfig",
  config = function()
    vim.api.nvim_set_keymap(
      "n",
      "K",
      "<cmd>lua require('plugins.lspconfig')" .. ".show_definition()<CR>",
      { noremap = true }
    )
    vim.api.nvim_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.hover()<CR>", {
      noremap = true,
    })
    vim.api.nvim_set_keymap(
      "n",
      "<C-d>",
      "<cmd>lua vim.diagnostic.open_float()<CR>",
      {
        noremap = true,
      }
    )
    vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {
      noremap = true,
    })
  end,
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
}

---Show definition of symbol under cursor, unless
---there are any diagnostics on the current line.
---Then display those diagnostics instead.
function M.show_definition()
  if vim.diagnostic.open_float() then
    return
  end
  vim.lsp.buf.hover()
end

function M.add_language_server(v)
  local server
  local opt = {}
  if type(v) == "table" then
    server = v[1]
    opt = v[2] or {}
  else
    server = v
  end

  M.__enable_language_server(server, opt, true)

  M.servers = M.servers or {}
  table.insert(M.servers, { server, opt })
end

function M.__enable_language_server(server, opt, start_lsp)
  local lspconfig = require "lspconfig"

  if opt.capabilities == nil then
    opt.capabilities = require("cmp_nvim_lsp").default_capabilities()
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

  lsp.setup(opt)

  if start_lsp then
    local ok, e = pcall(vim.fn.execute, "LspStart", true)
    if ok == false then
      vim.notify("Failed to start LSP: " .. e, vim.log.levels.WARN)
    end
  end
end

return M
