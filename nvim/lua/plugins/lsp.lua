--=============================================================================
-------------------------------------------------------------------------------
--                                                                     LSP.NVIM
--[[===========================================================================
https://github.com/lpoto/lsp.nvim

Keymaps:

  LSP:
  - "K"         -  Show the definition of symbol under the cursor
  - "<C-k>"     -  Show the diagnostics of the line under the cursor
  - "gd"        -  Go to the definition of symbol under cursor
  - "gr"        -  Show references to the symbol under the cursor
  - "<leader>r" -  Rename symbol under cursor

  - "<leader>f" - format the current buffer or visual selection
-----------------------------------------------------------------------------]]
local M = {
  {
    "lpoto/lsp.nvim",
  },
  -- lsp.nvim extensions
  "neovim/nvim-lspconfig",
  "mhartington/formatter.nvim",
  "mfussenegger/nvim-lint",
  "mfussenegger/nvim-jdtls",
}

local lsp_config
M[1].config = function()
  require("lsp").setup({
    extensions = {
      lspconfig = true,
      formatter = true,
      lint = true,
      cmp = true,
      jdtls = true,
    },
  })
  lsp_config()
end

local open_diagnostic_float
function lsp_config()
  vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
  vim.keymap.set("n", "<C-k>", open_diagnostic_float, {})
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
  vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
  vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, {})

  local format = function(visual) return require("lsp").format(visual) end
  vim.keymap.set("n", "<leader>f", format)
  vim.keymap.set("v", "<leader>f", function() format(true) end)

  local border = "single"
  vim.lsp.handlers["textDocument/hover"] =
    vim.lsp.with(vim.lsp.handlers.hover, {
      border = border,
    })
  vim.lsp.handlers["textDocument/signatureHelp"] =
    vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = border,
    })
  vim.diagnostic.config({
    float = { border = border },
    virtual_text = true,
    underline = { severity = "Error" },
    severity_sort = true,
  })
end

function open_diagnostic_float()
  local n, _ = vim.diagnostic.open_float()
  if not n then
    vim.notify("No diagnostics found", vim.log.levels.WARN, { title = "LSP" })
  end
end

return M
