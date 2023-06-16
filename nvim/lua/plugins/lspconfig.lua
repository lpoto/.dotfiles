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

local open_diagnostic_float
local configure_vim_diagnostic
function M.init()
  vim.keymap.set("n", "K", vim.lsp.buf.hover)
  vim.keymap.set("n", "<leader>K", open_diagnostic_float)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition)
  vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)

  configure_vim_diagnostic()
end

function open_diagnostic_float()
  local n, _ = vim.diagnostic.open_float()
  if not n then
    Util.log():warn("No diagnostics found")
  end
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

local launch_server_timer

---Override the default attach_language_server function.
---@param server string
---@param opts table?: Optional server configuration
---@diagnostic disable-next-line: duplicate-set-field
Util.misc().attach_language_server = function(server, opts)
  if type(server) ~= "string" or server:len() == 0 then
    Util.log():warn("No server provided")
    return
  end
  Util.require(
    { "lspconfig", "lspconfig.configs" },
    function(lspconfig, configs)
      local lsp = lspconfig[server]
      if lsp == nil then
        Util.log():warn("Language server not found:", server)
        return
      end

      Util.misc().ensure_source_installed("lspconfig-source", server)

      opts = vim.tbl_deep_extend(
        "force",
        opts or {},
        vim.g[server .. "_config"] or {}
      )
      opts.capabilities = opts.capabilities
        or Util.misc().get_autocompletion_capabilities()
      if opts.autostart == nil then
        opts.autostart = true
      end

      if opts.on_attach == nil then
        opts.on_attach = function(_)
          Util.log():debug("Attached to language server:", server)
        end
      end
      --- NOTE: try to launch the server in a timer, in case it is not
      --- installed yet. And we wait for the mason to install it.
      launch_server_timer(server, opts, lspconfig, configs)
    end
  )
end

local launch_server
function launch_server_timer(server, opts, lspconfig, configs, repeat_count)
  repeat_count = repeat_count or 0
  vim.defer_fn(function()
    if launch_server(server, opts, lspconfig, configs) then
      return
    end
    if (repeat_count + 2) % 5 == 0 then
      Util.log():debug("Waiting to start language server:", server, "...")
    end
    return launch_server_timer(
      server,
      opts,
      lspconfig,
      configs,
      repeat_count + 1
    )
  end, repeat_count == 0 and 100 or 2000)
end

function launch_server(server, opts, lspconfig, configs)
  pcall(lspconfig[server].setup, opts)
  local cfg = configs[server]
  if type(cfg) ~= "table" or not next(cfg.cmd or {}) then
    return true
  end
  local _, e = pcall(vim.fn.executable, cfg.cmd[1])
  if e ~= 1 then
    return false
  end
  local ok, err = pcall(cfg.launch)
  if not ok then
    Util.log():error("Error launching language server:", err)
    return true
  end
  return true
end

return M
