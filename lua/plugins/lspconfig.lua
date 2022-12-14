--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-LSPCONFIG
--=============================================================================
-- https://github.com/neovim/nvim-lspconfig
--_____________________________________________________________________________

local lspconfig = require("util.packer_wrapper").get "lspconfig"

---Jump to definition with "gd"
---Definition of word under the cursor with "shift + K"
---If there are diagnostics on line the "shit + K " will display
---diagnostics instead.
---"Ctrl + k" will show only definition.
---"Ctrl + d" will show only diagnostics.
lspconfig:config(function()
  vim.api.nvim_set_keymap(
    "n",
    "K",
    "<cmd>lua require('util.packer_wrapper')"
      .. ".get('lspconfig'):run('show_definition')<CR>",
    {
      silent = true,
      noremap = true,
    }
  )
  vim.api.nvim_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.hover()<CR>", {
    silent = true,
    noremap = true,
  })
  vim.api.nvim_set_keymap(
    "n",
    "<C-d>",
    "<cmd>lua vim.diagnostic.open_float()<CR>",
    {
      silent = true,
      noremap = true,
    }
  )
  vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {
    silent = true,
    noremap = true,
  })
end, "remappings")

---Show definition of symbol under cursor, unless
---there are any diagnostics on the current line.
---Then display those diagnostics instead.
lspconfig:action("show_definition", function()
  if vim.diagnostic.open_float() then
    return
  end
  vim.lsp.buf.hover()
end)

lspconfig:action("start", function()
  local ok, e = require "lspconfig"
  if ok == false then
    require("util.log").warn(e)
    return
  end
  vim.cmd("LspStart", true)
end)
