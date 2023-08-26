--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-LSPCONFIG
--[[===========================================================================
https://github.com/neovim/nvim-lspconfig

Keymaps:
  - "K"         -  Show the definition of symbol under the cursor
  - "<C-d>"     -  Show the diagnostics of the line under the cursor
  - "<leader>r" -  Rename symbol under cursor
-----------------------------------------------------------------------------]]
local M = {
  "neovim/nvim-lspconfig",
  cmd = { "LspStart", "LspInfo" },
}

local open_diagnostic_float
local configure_vim_diagnostic
local on_lsp_attach
function M.init()
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      vim.schedule(function() on_lsp_attach(args) end)
    end,
  })

  configure_vim_diagnostic()
end

local logged = {}
function on_lsp_attach(args)
  if
    type(args) == "table"
    and type(args.data) == "table"
    and type(args.data.client_id) == "number"
  then
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local name = (client or {}).name
    if
      type(name) == "string"
      and name:len() > 0
      and name ~= "null-ls"
      and not logged[name]
    then
      logged[name] = true
      Util.log("LSP"):debug("Attached to server:", name)
    end
  end
  if
    not type(args.buf) == "number" or not vim.api.nvim_buf_is_valid(args.buf)
  then
    return
  end
  local opts = { buffer = args.buf }
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<C-d>", open_diagnostic_float, opts)
  -- NOTE: the lsp definitions and references are used with telescope.nvim
  -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  -- vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
end

function open_diagnostic_float()
  local n, _ = vim.diagnostic.open_float()
  if not n then Util.log("LSP"):warn("No diagnostics found") end
end

function configure_vim_diagnostic()
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

---Override the default attach_language_server function.
---@param server string|table
---@diagnostic disable-next-line: duplicate-set-field
Util.misc().attach_language_server = function(server)
  if type(server) == "string" then server = {
    name = server,
  } end
  if type(server) ~= "table" then
    Util.log():warn("No server provided")
    return
  end
  if type(server.name) ~= "string" and type(server[1]) == "string" then
    server.name = server[1]
  end
  if type(server.name) ~= "string" then
    Util.log():warn("No language server name provided")
    return
  end
  server[1] = nil
  Util.require("lspconfig", function(lspconfig)
    local lsp = lspconfig[server.name]
    if lsp == nil then
      Util.log():warn("Language server not found:", server)
      return
    end

    server = vim.tbl_deep_extend(
      "force",
      server or {},
      vim.g[server.name .. "_config"] or {}
    )
    server.capabilities = server.capabilities
      or Util.misc().get_autocompletion_capabilities()

    if server.root_dir == nil and type(server.root_patterns) == "table" then
      server.root_dir = Util.misc().root_fn(server.root_patterns)
    end

    lsp.setup(server)
    vim.api.nvim_exec("LspStart", false)
  end)
end

return M
