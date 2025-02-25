--=============================================================================
--                                     https://github.com/neovim/nvim-lspconfig
--[[===========================================================================

A collection of LSP configurations

Keymaps:

  - "K"         -  Show the definition of symbol under the cursor

  - "gd"        -  Go to the definitions of symbol under cursor
  - "gi"        -  Go to the implementations of symbol under cursor
  - "gr"        -  Go to the references to the symbol under the cursor

  - "<leader>e" -  Show the diagnostics of the line under the cursor

  - "<leader>a" -  Show code actions for the current position
  - "<leader>r" -  Rename symbol under cursor
-----------------------------------------------------------------------------]]

local M = {
  "neovim/nvim-lspconfig",
  tag = "v1.4.0",
  cmd = { "LspInfo", "LspStart", "LspLog" },
}

local util = {}
function M.config()
  require("lspconfig.ui.windows").default_options.border = "single"
end

function M.init()
  util.set_up_autocommands()
  util.set_lsp_keymaps()
  util.set_lsp_handlers()
end

function util.set_lsp_keymaps(opts)
  for _, o in ipairs {
    { "n", "K", vim.lsp.buf.hover },
    { { "n", "v" }, "<leader>a", vim.lsp.buf.code_action },
    { "n", "<leader>r", vim.lsp.buf.rename },
    { "n", "<leader>a", vim.lsp.buf.code_action },
    --
    -- NOTE: These keymaps are set by fzf-lua
    --
    --{ "n", "gd", vim.lsp.buf.definition },
    --{ "n", "gi", vim.lsp.buf.implementation },
    --{ "n", "gr", vim.lsp.buf.references },
    --{ "n", "<leader>e", vim.diagnostic.open_float },
  } do
    if vim.tbl_contains({ "", nil, 0 }, vim.fn.mapcheck(o[2])) then
      vim.keymap.set(o[1], o[2], o[3], opts)
    end
  end
end

function util.set_lsp_handlers()
  local border = "single"
  vim.lsp.handlers["textDocument/hover"] =
    vim.lsp.with(vim.lsp.handlers.hover, {
      border = border,
    })
  vim.lsp.handlers["textDocument/signatureHelp"] =
    vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = border,
    })
  vim.diagnostic.config {
    float = { border = border },
    virtual_text = true,
    underline = { severity = vim.diagnostic.severity.ERROR },
    severity_sort = true,
  }
end

function util.set_up_autocommands()
  vim.api.nvim_create_autocmd("Filetype", {
    group = vim.api.nvim_create_augroup("lspconfig.Ft", { clear = true }),
    callback = util.filetype_autocommand,
  })
end

function util.filetype_autocommand()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo.filetype
  local loaded = filetype .. "_lspconfig_loaded"
  if vim.g[loaded] then return end

  vim.defer_fn(function()
    if vim.api.nvim_get_current_buf() ~= buf or vim.g[loaded] then return end
    vim.g[loaded] = true

    local function attach()
      local opts = vim.g[filetype]
      if type(opts) == "function" then
        local ok, v = pcall(opts)
        if not ok then
          return vim.api.nvim_err_writeln(
            "Error in filetype config function: " .. v
          )
        end
        opts = v
        vim.g[filetype] = opts
      end
      util.attach(buf, opts)
    end
    attach()
  end, 350)
end

function util.attach(bufnr, opts)
  if type(opts) ~= "table" then return end
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  local server =
    util.expand_config(filetype, opts.language_server or opts.server)
  if not server then return end

  if
    type(vim.g.attached) == "table"
    and vim.tbl_contains(vim.g.attached, server.name)
  then
    return
  end
  opts.language_server = server
  opts.server = nil

  local ok, lsp = pcall(function() return require("lspconfig")[server.name] end)

  if not ok or not lsp then return end

  ---@type table
  local client = (vim.lsp.get_clients { name = server.name } or {})[1]

  server.filetypes = server.filetypes or { filetype }

  if type(client) == "table" and type(client.config) == "table" then
    local filetypes = client.config.filetypes
    if filetypes == nil and type(client.settings) == "table" then
      filetypes = client.settings.filetypes
    end

    if type(filetypes) == "string" then
      filetypes = { filetypes }
    elseif type(filetypes) ~= "table" then
      filetypes = {}
    end
    if type(server.filetypes) == "string" then
      server.filetypes = { server.filetypes }
    elseif type(server.filetypes) ~= "table" then
      server.filetypes = {}
    end
    for _, ft in ipairs(filetypes) do
      if not vim.tbl_contains(server.filetypes, ft) then
        table.insert(server.filetypes, ft)
      end
    end
  end
  local has_cmp, cmp = pcall(require, "cmp_nvim_lsp")
  if has_cmp then
    server.capabilities = vim.tbl_extend(
      "force",
      cmp.default_capabilities(),
      server.capabilities or {}
    )
  end

  lsp.setup(server)
  local config
  ok, config = pcall(
    function() return require("lspconfig.configs")[server.name] end
  )
  if ok and config then config.launch(bufnr) end
end

function util.expand_config(filetype, opts)
  if type(opts) ~= "table" then opts = { name = opts } end

  local g_opts = vim.g[filetype .. "_language_server"]
    or vim.g[filetype .. "_server"]
  if type(g_opts) == "string" then
    opts = { name = g_opts }
  elseif type(g_opts) == "table" then
    opts = vim.tbl_deep_extend("force", opts, g_opts)
  end
  if type(opts.name) ~= "string" then return end
  return opts
end

return M
