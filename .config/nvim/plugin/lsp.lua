-- NOTE: Override default lsp enable, so that
-- we may call the enable from ftplugin files
local f = vim.lsp.enable
---@diagnostic disable-next-line
vim.lsp.enable = function(...)
  f(...)
  if vim.bo.filetype ~= "" and vim.bobuftype ~= "" then
    vim.api.nvim_exec_autocmds("FileType", {
      group = "nvim.lsp.enable",
    })
  end
end

local format_util = {}

format_util.format = vim.lsp.buf.format

---@diagnostic disable-next-line
vim.lsp.buf.format = function(opts)
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
    table.insert(client_names, client.name)
  end

  if opts.async == nil then
    opts.async = true
  end

  format_util.show_dbg_message("Formatting with: " ..
    table.concat(client_names, ", "))

  format_util.format(opts)

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

-- NOTE: enable all lsp servers defined in lua/lsp
local function get_defined_language_servers()
  local lsp_dir = vim.fn.stdpath "config" .. "/lsp/"
  local files = {}
  ---@diagnostic disable-next-line
  local fs = vim.loop.fs_scandir(lsp_dir)
  if not fs then return {} end
  while true do
    ---@diagnostic disable-next-line
    local name, type = vim.loop.fs_scandir_next(fs)
    if not name then break end -- Stop when there are no more files
    local name_without_ext = name:match "(.+)%..+$" or name
    table.insert(files, name_without_ext)
  end
  return files
end

vim.lsp.enable(get_defined_language_servers())
