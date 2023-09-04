--=============================================================================
-------------------------------------------------------------------------------
--                                                                     LSP.NVIM
--[[===========================================================================
https://github.com/lpoto/lsp.nvim
https://github.com/neovim/nvim-lspconfig
https://github.com/creativenull/efmls-configs-nvim

A high-level interface for attaching servers, formatters
and linters to neovim's LSP.

Keymaps:
  - "K"         -  Show the definition of symbol under the cursor
  - "<C-k>"     -  Show the diagnostics of the line under the cursor
  - "<leader>r" -  Rename symbol under cursor

  - "<leader>f" - format the current buffer or visual selection
-----------------------------------------------------------------------------]]
local M = {
  "lpoto/lsp.nvim",
  cmd = { "LspStart", "LspInfo", "LspLog" },
  dependencies = {
    "neovim/nvim-lspconfig",
    "creativenull/efmls-configs-nvim",
  },
  opts = {
    extensions = {
      efm = true,
      cmp = true,
    },
  },
}

local open_diagnostic_float

function M.init()
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      vim.schedule(function()
        local opts = { buffer = args.buf }
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<C-k>", open_diagnostic_float, opts)
        -- NOTE: the lsp definitions and references are used with telescope.nvim
        -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        -- vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
      end)
    end,
  })
  local format = function(visual) return require("lsp.core").format(visual) end
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

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.handlers["window/showMessage"] = function(
    _,
    method,
    params,
    client_id
  )
    local client = vim.lsp.get_client_by_id(client_id)
    vim.notify(method.message, 5 - params.type, {
      title = (client or {}).name,
    })
  end
end

function open_diagnostic_float()
  local n, _ = vim.diagnostic.open_float()
  if not n then
    vim.notify("No diagnostics found", vim.log.levels.WARN, { title = "LSP" })
  end
end

return M
