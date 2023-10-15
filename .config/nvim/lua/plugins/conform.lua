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
  cmd = 'ConformInfo',
}

vim.lsp.add_attach_condition {
  priority = 25,
  fn = function(opts, _, filetype)
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

local formatted_with = nil
local default_format_opts = {
  async = false,
  lsp_fallback = true,
  timeout_ms = 2000,
  filter = function(client)
    if
      type(client) == 'table'
      and type(client.server_capabilities) == 'table'
      and client.server_capabilities.documentFormattingProvider
    then
      if formatted_with == nil then
        formatted_with = {}
      end
      if not vim.tbl_contains(formatted_with, client.name) then
        table.insert(formatted_with, client.name)
      end
      return true
    end
  end
}
local default_format_callback = function(err)
  local formatters = formatted_with or {}
  formatted_with = nil
  if err ~= nil then
    vim.notify(err, vim.log.levels.WARN, {
      title = 'Conform',
    })
    return
  end
  formatters = vim.tbl_filter(function(n)
    -- NOTE: filter some formatters and language
    -- servers that notify themselves
    return not vim.tbl_contains({ 'pylsp' }, n)
  end, formatters)
  if not next(formatters) then return end
  vim.defer_fn(function()
    local s = #formatters > 1 and vim.inspect(formatters) or formatters[1]
    if type(vim.g.display_message) == 'function' then
      vim.g.display_message {
        message = 'formatted with: ' .. s,
        title = 'Conform',
      }
    else
      vim.notify(
        'formatted with: ' .. s,
        vim.log.levels.DEBUG,
        { title = 'Conform' }
      )
    end
  end, 100)
end

local function format(opts, callback)
  opts = vim.tbl_extend('force', default_format_opts, opts or {})
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


  print(vim.inspect(formatted_with))
  require 'conform'.format(opts, callback)
end

M.keys = {
  { '<leader>f', format, mode = { 'n', 'v' } }
}

return M
