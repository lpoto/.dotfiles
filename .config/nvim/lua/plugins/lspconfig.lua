--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-LSPCONFIG
--[[===========================================================================
https://github.com/neovim/nvim-lspconfig

A collection of LSP configurations

Keymaps:

  - "K"         -  Show the definition of symbol under the cursor

  - "gd"        -  Go to the definitions of symbol under cursor
  - "gi"        -  Go to the implementations of symbol under cursor
  - "gr"        -  Go to the references to the symbol under the cursor

  - "<leader>d" -  Show the diagnostics of the line under the cursor

  - "<leader>a" -  Show code actions for the current position
  - "<leader>r" -  Rename symbol under cursor
-----------------------------------------------------------------------------]]

local M = {
  'neovim/nvim-lspconfig',
  cmd = { 'LspInfo', 'LspStart', 'LspLog' },
}

local util = {}
function M.config()
  require 'lspconfig.ui.windows'.default_options.border = 'single'
end

function M.init()
  util.set_up_autocommands()
  util.set_lsp_keymaps()
  util.set_lsp_handlers()
end

function util.set_lsp_keymaps(opts)
  for _, o in ipairs {
    { 'n', 'K',         vim.lsp.buf.hover },
    { 'n', 'gd',        vim.lsp.buf.definition },
    { 'n', 'gi',        vim.lsp.buf.implementation },
    { 'n', 'gr',        vim.lsp.buf.references },
    { 'n', '<leader>d', vim.diagnostic.open_float },
    { 'n', '<leader>a', vim.lsp.buf.code_action },
    { 'n', '<leader>r', vim.lsp.buf.rename },
  } do
    if vim.tbl_contains({ '', nil, 0 }, vim.fn.mapcheck(o[2])) then
      vim.keymap.set(o[1], o[2], o[3], opts)
    end
  end
end

function util.set_lsp_handlers()
  local border = 'single'
  vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, {
      border = border,
    })
  vim.lsp.handlers['textDocument/signatureHelp'] =
    vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = border,
    })
  vim.diagnostic.config {
    float = { border = border },
    virtual_text = true,
    underline = { severity = 'Error' },
    severity_sort = true,
  }
end

function util.set_up_autocommands()
  vim.api.nvim_create_autocmd('Filetype', {
    group = vim.api.nvim_create_augroup('lspconfig.Ft', { clear = true }),
    callback = util.filetype_autocommand
  })
end

function util.filetype_autocommand()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo.filetype
  local loaded = filetype .. '_lspconfig_loaded'
  if vim.g[loaded] then return end

  vim.defer_fn(function()
    if vim.api.nvim_get_current_buf() ~= buf or vim.g[loaded] then
      return
    end
    vim.g[loaded] = true

    local function attach()
      local opts = vim.g[filetype]
      if type(opts) == 'function' then
        local ok, v = pcall(opts)
        if not ok then
          return vim.api.nvim_err_writeln(
            'Error in filetype config function: ' .. v
          )
        end
        opts = v
        vim.g[filetype] = opts
      end
      util.attach(buf, opts)
    end
    attach()
    util.log_attached(100)
  end, 350)
end

function util.attach(bufnr, opts)
  if type(opts) ~= 'table' then return end
  local server = opts.language_server or opts.server
  if type(server) == 'string' then server = { name = server } end
  if type(server) ~= 'table' then return end
  if type(vim.g.attached) == 'table' and
    vim.tbl_contains(vim.g.attached, server.name) then
    return
  end
  local ok = pcall(require, 'lspconfig.server_configurations.' .. server.name)
  local lsp = ok and require 'lspconfig'[server.name]

  if not ok or not lsp then
    return util.add_to_not_attached(server.name)
  end

  ---@type table
  local client = (vim.lsp.get_clients { name = server.name } or {})[1]

  local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
  server.filetypes = server.filetypes or { filetype }

  if type(client) == 'table' and
    type(client.config) == 'table' then
    local filetypes = client.config.filetypes
    if filetypes == nil and type(client.settings) == 'table' then
      filetypes = client.settings.filetypes
    end

    if type(filetypes) == 'string' then
      filetypes = { filetypes }
    elseif type(filetypes) ~= 'table' then
      filetypes = {}
    end
    if type(server.filetypes) == 'string' then
      server.filetypes = { server.filetypes }
    elseif type(server.filetypes) ~= 'table' then
      server.filetypes = {}
    end
    for _, ft in ipairs(filetypes) do
      if not vim.tbl_contains(server.filetypes, ft) then
        table.insert(server.filetypes, ft)
      end
    end
  end
  server.autostart = true
  local has_cmp, cmp = pcall(require, 'cmp_nvim_lsp')
  if has_cmp then
    server.capabilities = vim.tbl_extend(
      'force',
      cmp.default_capabilities(),
      server.capabilities or {}
    )
  end

  lsp.setup(server)
  local config = require 'lspconfig.configs'[server.name]
  config.launch(bufnr)

  util.add_to_attached(server.name)
end

function util.log_attached(delay)
  if type(delay) ~= 'number' then delay = 500 end
  local attached = vim.g.attached
  local not_attached = vim.g.not_attached
  if (type(attached) ~= 'table' or not next(attached)) and
    (type(not_attached) ~= 'table' or not next(not_attached)) then
    return
  end
  vim.defer_fn(function()
    attached = vim.g.attached
    not_attached = vim.g.not_attached
    vim.g.attached = nil
    vim.g.not_attached = nil

    local l = vim.log.levels.INFO
    local s = ''
    if type(attached) == 'table' and next(attached) then
      s = 'Attached: [' .. table.concat(attached, ', ') .. ']'
    end
    if type(not_attached) == 'table' and next(not_attached) then
      if s:len() > 0 then s = s .. ', ' end
      s = s
        .. 'Failed to attach: ['
        .. table.concat(not_attached, ', ')
        .. ']'
      l = vim.log.levels.WARN
    end
    if s:len() > 0 then vim.notify(s, l) end
    M.__logs = {}
  end, delay)
end

function util.add_to_attached(name)
  local attached = vim.g.attached
  if type(attached) ~= 'table' then
    attached = {}
  end
  table.insert(attached, name)
  vim.g.attached = attached
end

function util.add_to_not_attached(name)
  local not_attached = vim.g.not_attached
  if type(not_attached) ~= 'table' then
    not_attached = {}
  end
  table.insert(not_attached, name)
  vim.g.not_attached = not_attached
end

return M
