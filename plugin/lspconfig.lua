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

local plugin = require("plugin").new {
  "neovim/nvim-lspconfig",
  as = "lspconfig",
  cmd = "LspStart",
  config = function()
    local mapper = require "mapper"

    mapper.map(
      "n",
      "K",
      "<cmd>lua require('plugin')"
        .. ".get('lspconfig'):run('show_definition')<CR>"
    )
    mapper.map("n", "<C-k>", "<cmd>lua vim.lsp.buf.hover()<CR>")
    mapper.map("n", "<C-d>", "<cmd>lua vim.diagnostic.open_float()<CR>")
    mapper.map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
  end,
}

---Show definition of symbol under cursor, unless
---there are any diagnostics on the current line.
---Then display those diagnostics instead.
plugin:action("show_definition", function()
  if vim.diagnostic.open_float() then
    return
  end
  vim.lsp.buf.hover()
end)
