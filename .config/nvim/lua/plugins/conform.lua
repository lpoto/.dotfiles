--=============================================================================
-------------------------------------------------------------------------------
--                                                                 CONFORM.NVIM
--[[===========================================================================
https://github.com/stevearc/conform.nvim

Keymaps:
  <leader>f  - Format the current buffer (or visual selection)
-----------------------------------------------------------------------------]]

local M = {
  'stevearc/conform.nvim',
}

local util = {}
function M.init()
  vim.keymap.set({ 'n', 'v' }, '<leader>f', util.format)

  util.set_up_autocommands()
end

function util.set_up_autocommands()
  vim.api.nvim_create_autocmd('Filetype', {
    group = vim.api.nvim_create_augroup('conform.Ft', { clear = true }),
    callback = util.filetype_autocommand
  })
end

function util.filetype_autocommand()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo.filetype
  if vim.g[filetype .. '_conform_loaded'] then return end

  vim.defer_fn(function()
    if vim.api.nvim_get_current_buf() ~= buf or
      vim.g[filetype .. '_conform_loaded'] then
      return
    end
    vim.g[filetype .. '_conform_loaded'] = true

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
  end, 250)
end

function util.attach(buf, opts)
  if type(opts) ~= 'table' then return end
  local formatter = opts.formatter or opts.format
  if type(formatter) == 'string' then formatter = { name = formatter } end
  if type(formatter) ~= 'table' then return end
  if type(vim.g.attached) == 'table' and
    vim.tbl_contains(vim.g.attached, formatter.name) then
    return
  end

  local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
  local ok = pcall(require, 'conform.formatters.' .. formatter.name)
  if not ok then
    return util.add_to_not_attached(formatter.name)
  end
  local conform = require 'conform'
  conform.setup {
    lsp_fallback = true,
    formatters_by_ft = {
      [filetype] = { formatter.name }
    }
  }
  for _, tbl in ipairs(conform.list_formatters(buf) or {}) do
    if type(tbl) == 'table' and type(tbl.name) == 'string' then
      if tbl.name == formatter.name then
        local server = opts.language_server or opts.server
        if type(server) == 'string' then server = { name = server } end
        if type(server) == 'table' then
          local f = server.on_attach
          if not f then
            server.on_attach = function(c)
              if type(c) == 'table' then
                if type(c.server_capabilities) ~= 'table' then
                  c.server_capabilities = {}
                end
                c.server_capabilities.documentFormattingProvider = false
                c.server_capabilities.documentRangeFormattingProvider = false
              end
              if type(f) == 'function' then
                return f(c)
              end
            end
            opts.server = nil
            opts.language_server = server
            vim.g[filetype] = opts
          end
        end

        return util.add_to_attached(formatter.name)
      end
    end
  end
  return util.add_to_not_attached(formatter.name)
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

function util.format(opts, callback)
  if type(opts) ~= 'table' then opts = {} end
  opts = vim.tbl_extend('force', util.default_format_opts(opts), opts)

  if type(callback) ~= 'function' then callback = util.default_format_callback end

  local buf = vim.api.nvim_get_current_buf()
  local conform = require 'conform'
  util.formatted_with = {}
  for _, tbl in ipairs(conform.list_formatters(buf) or {}) do
    if type(tbl) == 'table' and type(tbl.name) == 'string' then
      table.insert(util.formatted_with, tbl.name)
    end
  end
  if not next(util.formatted_with) then util.formatted_with = nil end
  return require 'conform'.format(opts, callback)
end

function util.default_format_opts(opts)
  if type(opts) ~= 'table' then opts = {} end
  local method = 'textDocument/formatting'
  if opts.range then
    method = 'textDocument/rangeFormatting'
  end
  local potential_clients = vim.lsp.get_clients {
    bufnr = opts.bufnr or vim.api.nvim_get_current_buf(),
    method = method,
  }
  if type(potential_clients) ~= 'table' then potential_clients = {} end

  return {
    async = false,
    lsp_fallback = true,
    timeout_ms = 2000,
    filter = function(client)
      if type(client) ~= 'table' or
        type(client.name) ~= 'string' or
        not client.id
      then
        return false
      end
      for _, c in ipairs(potential_clients) do
        if c.id == client.id then
          if util.formatted_with == nil then
            util.formatted_with = {}
          end
          if not vim.tbl_contains(util.formatted_with, client.name) then
            table.insert(util.formatted_with, client.name)
          end
          return true
        end
      end
      return false
    end
  }
end

function util.default_format_callback(err)
  local formatters = util.formatted_with or {}
  util.formatted_with = nil
  if err ~= nil then
    vim.notify(err, vim.log.levels.WARN)
    return
  end
  formatters = vim.tbl_filter(function(n)
    -- NOTE: filter some formatters and language
    -- servers that notify themselves
    return not vim.tbl_contains({ 'pylsp' }, n)
  end, formatters)
  if not next(formatters) then return end
  vim.defer_fn(function()
    local s = #formatters > 1 and table.concat(formatters, ', ') or formatters
      [1]
    if type(vim.g.display_message) == 'function' then
      local ok, _ = pcall(vim.g.display_message, {
        message = 'formatted with: ' .. s,
        title = 'Conform',
      })
      if ok then return end
    end
    vim.notify('formatted with: ' .. s, vim.log.levels.DEBUG)
  end, 10)
end

return M
