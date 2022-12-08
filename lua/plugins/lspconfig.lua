--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-LSPCONFIG
--=============================================================================
-- https://github.com/neovim/nvim-lspconfig
--_____________________________________________________________________________

local lspconfig = {}

---Jump to definition with "gd"
---Definition of word under the cursor with "shift + K"
---If there are diagnostics on line the "shit + K " will display
---diagnostics instead.
---"Ctrl + k" will show only definition.
function lspconfig.init()
  vim.api.nvim_set_keymap(
    "n",
    "K",
    "<cmd>lua require('plugins.lspconfig').show_definition()<CR>",
    {
      silent = true,
      noremap = true,
    }
  )
  vim.api.nvim_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.hover()<CR>", {
    silent = true,
    noremap = true,
  })
  vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {
    silent = true,
    noremap = true,
  })
end

---Show definition of symbol under cursor, unless
---there are any diagnostics on the current line.
---Then display those diagnostics instead.
function lspconfig.show_definition()
  if vim.diagnostic.open_float() then
    return
  end
  vim.lsp.buf.hover()
end

local distinct_setups = {}

---Create a distinct setup, identifies by the provided key.
---Once this is called, calling it again with the same key will
---be a no-op, unless override is true.
---
---NOTE: this is useful for setting local configs and ignoring
---the default distinct configs.
---
---@param key string: A string to identify the setup
---@param f function: A lspconfig setup function
---@param override boolean?: Override existing config.
function lspconfig.distinct_setup(key, f, override)
  if override ~= true and distinct_setups[key] ~= nil then
    return
  end
  f()
  distinct_setups[key] = true
end

return lspconfig
