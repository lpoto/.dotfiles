--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-LSPCONFIG
--[[===========================================================================
https://github.com/neovim/nvim-lspconfig

Configuration for the built-in LSP client.
see github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
for server configurations.
Lsp is then enabled with ':LspStart' (this is usually done automatically for
filetypes in ftplguin/)


Keymaps:
  - "gd"    - jump to the definition of the symbol under cursor
  - "K" -  Show the definition of symbol under the cursor
  - "<C-d>" -  Show the diagnostics of the line under the cursor
  - "<leader>r" -  Rename symbol under cursor
-----------------------------------------------------------------------------]]
local M = {
  "neovim/nvim-lspconfig",
  cmd = { "LspStart", "LspInfo" },
}

function M.init()
  vim.keymap.set("n", "K", vim.lsp.buf.hover)
  vim.keymap.set("n", "<C-d>", vim.diagnostic.open_float)
  vim.keymap.set("n", "<leader>D", vim.diagnostic.open_float)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition)
  vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
end

---Override the default attach_language_server function.
---@param server string
---@param opts table?: Optional server configuration
---@diagnostic disable-next-line: duplicate-set-field
Util.misc().attach_language_server = function(server, opts)
  if type(server) ~= "string" or server:len() == 0 then
    Util.log():warn("No server provided")
    return
  end
  vim.schedule(function()
    Util.require("lspconfig", function(lspconfig)
      local lsp = lspconfig[server]
      if lsp == nil then
        Util.log():warn("Language server not found:", server)
        return
      end
      opts = vim.tbl_deep_extend(
        "force",
        opts or {},
        vim.g[server .. "_config"] or {}
      )
      opts.capabilities = opts.capabilities
        or Util.misc().get_autocompletion_capabilities()
      lsp.setup(opts)
      vim.api.nvim_exec("LspStart", true)
    end)
  end)
end

return M
