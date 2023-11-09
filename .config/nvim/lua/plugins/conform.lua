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

vim.lsp.add_attach_condition {
  priority = 25,
  fn = function(opts, buf)
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
    local ok = pcall(require, 'conform.formatters.' .. opts.name)
    if not ok then
      return {
        missing = { opts.name },
      }
    end
    require 'conform'.setup {
      lsp_fallback = true,
      formatters_by_ft = {
        [filetype] = { opts.name }
      }
    }
    return { attached = { opts.name } }
  end,
}

local formatted_with, default_format_opts, default_format_callback
local function format(opts, callback)
  if type(opts) ~= 'table' then opts = {} end
  opts = vim.tbl_extend('force', default_format_opts(opts), opts)

  if type(callback) ~= 'function' then callback = default_format_callback end

  local buf = vim.api.nvim_get_current_buf()
  local conform = require 'conform'
  formatted_with = {}
  for _, tbl in ipairs(conform.list_formatters(buf) or {}) do
    if type(tbl) == 'table' and type(tbl.name) == 'string' then
      table.insert(formatted_with, tbl.name)
    end
  end
  if not next(formatted_with) then formatted_with = nil end
  return require 'conform'.format(opts, callback)
end

M.keys = {
  { '<leader>f', format, mode = { 'n', 'v' } }
}

function default_format_opts(opts)
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
          if formatted_with == nil then
            formatted_with = {}
          end
          if not vim.tbl_contains(formatted_with, client.name) then
            table.insert(formatted_with, client.name)
          end
          return true
        end
      end
      return false
    end
  }
end

function default_format_callback(err)
  local formatters = formatted_with or {}
  formatted_with = nil
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
