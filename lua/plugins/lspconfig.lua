--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-LSPCONFIG
--=============================================================================
-- https://github.com/neovim/nvim-lspconfig
--_____________________________________________________________________________

local lspconfig = require("util.packer.wrapper").get "lspconfig"

---Jump to definition with "gd"
---Definition of word under the cursor with "shift + K"
---If there are diagnostics on line the "shit + K " will display
---diagnostics instead.
---"Ctrl + k" will show only definition.
---"Ctrl + d" will show only diagnostics.
lspconfig:config(function()
  local mapper = require "util.mapper"

  mapper.map(
    "n",
    "K",
    "<cmd>lua require('util.packer.wrapper')"
      .. ".get('lspconfig'):get_field('show_definition')()<CR>"
  )
  mapper.map("n", "<C-k>", "<cmd>lua vim.lsp.buf.hover()<CR>")
  mapper.map("n", "<C-d>", "<cmd>lua vim.diagnostic.open_float()<CR>")
  mapper.map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
end, "remappings")

---Show definition of symbol under cursor, unless
---there are any diagnostics on the current line.
---Then display those diagnostics instead.
lspconfig:add_field("show_definition", function()
  if vim.diagnostic.open_float() then
    return
  end
  vim.lsp.buf.hover()
end)
