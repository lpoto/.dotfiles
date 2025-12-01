--=============================================================================
--                                     https://github.com/stevearc/conform.nvim
--[[===========================================================================

Override the defautl vim.lsp.buf.format to support conform formatters.

To use a conform formatter with lsp, add formater = "<value>" in lsp
server config.

-----------------------------------------------------------------------------]]

local M = {
  "stevearc/conform.nvim",
  commit = "4993e07"
}

local format_util = {}
function M.init()
  ---@diagnostic disable-next-line
  vim.lsp.buf.format = format_util.override_fn
end

format_util.lsp_format = vim.lsp.buf.format

function format_util.format_conform(formatter)
  if type(formatter) == "string" then
    local _, formatters = pcall(require, "conform.formatters")
    if type(formatters) ~= "table" or not formatters[formatter] then
      vim.notify(
        string.format("Formatter '%s' not found in existing formatters.",
          formatter),
        vim.log.levels.ERROR)
      return
    end
  else
    vim.notify(
      "Only default formatters are supported at the moment",
      vim.log.levels.ERROR)
    return
  end
  local opts = {
    bufnr = vim.api.nvim_get_current_buf(),
    async = false,
    stop_after_first = true,
    formatters = { formatter }
  }
  format_util.show_dbg_message("Formatting with: " .. formatter)

  local conform = require "conform"
  local filetype = vim.bo[opts.bufnr].filetype
  conform.setup {
    formatters_by_ft = {
      [filetype] = { formatter },
    },
    log_level = vim.log.levels.WARN,
    notify_no_formatters = false
  }
  conform.format(opts, function()
    format_util.show_dbg_message("Formatted with: " .. formatter)
  end)
end

function format_util.override_fn(opts)
  opts = opts or {}

  local buf = opts.bufnr or vim.api.nvim_get_current_buf()
  opts.bufnr = buf
  local range = opts.range

  local passed_multiple_ranges = (
    range
    and #range ~= 0
    and type(range[1]) == "table"
  )
  local method ---@type string
  local ms = require "vim.lsp.protocol".Methods
  if passed_multiple_ranges then
    method = ms.textDocument_rangesFormatting
  elseif range then
    method = ms.textDocument_rangeFormatting
  else
    method = ms.textDocument_formatting
  end

  local clients = vim.lsp.get_clients {
    id = opts.id,
    bufnr = buf,
    name = opts.name,
    method = method,
  }
  if opts.filter then clients = vim.tbl_filter(opts.filter, clients) end

  if #clients == 0 then
    format_util.show_dbg_message "Format request failed, no matching language servers."
    return
  end
  local client_names = {}
  for _, client in ipairs(clients) do
    if type(client) == "table" and
      type(client.config) == "table" and
      ---@diagnostic disable-next-line
      client.config.formatter ~= nil then
      vim.schedule(function()
        ---@diagnostic disable-next-line
        format_util.format_conform(client.config.formatter)
      end)
      return
    end
    table.insert(client_names, client.name)
  end

  if opts.async == nil then
    opts.async = true
  end

  format_util.show_dbg_message("Formatting with: " ..
    table.concat(client_names, ", "))

  format_util.lsp_format(opts)

  format_util.show_dbg_message("Formatted with: " ..
    table.concat(client_names, ", "))
end

function format_util.show_dbg_message(message)
  if type(vim.g.display_message) == "function" then
    local ok, _ = pcall(vim.g.display_message, {
      message = message,
      title = "LSP",
    })
    if ok then return end
  end
  vim.notify_once(message, vim.log.levels.DEBUG)
end

return M
