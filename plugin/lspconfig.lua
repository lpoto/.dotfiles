--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-LSPCONFIG
--=============================================================================
-- https://github.com/neovim/nvim-lspconfig
--_____________________________________________________________________________

---Jump to definition with "gd"
---Definition of word under the cursor with "shift + K"
---If there are diagnostics on line the "shit + K " will display
---diagnostics instead.
---"Ctrl + k" will show only definition.
---"Ctrl + d" will show only diagnostics.
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
