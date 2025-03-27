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

local show_dbg_message

--- NOTE: Override default lsp format to
--- perform organize imports action before formatting
local format = vim.lsp.buf.format

---@diagnostic disable-next-line
vim.lsp.buf.format = function(opts)
  opts = opts or {}

  local buf = opts.bufnr or vim.api.nvim_get_current_buf()
  local win = vim.fn.bufwinid(buf)
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
  local client_names = {}
  if opts.filter then clients = vim.tbl_filter(opts.filter, clients) end

  if #clients == 0 then
    show_dbg_message "Format request failed, no matching language servers."
    return
  end

  local mode = vim.api.nvim_get_mode().mode
  if mode == "n" and method == ms.textDocument_formatting then
    -- NOTE: When formatting the whole file in normal mode,
    -- also try to automatically organize imports
    for _, client in ipairs(clients) do
      table.insert(client_names, client.name)

      local enc = client.offset_encoding or "utf-16"
      local params = vim.lsp.util.make_range_params(win, enc)
      -- NOTE: We first check if client even supports
      -- fetching code actions, if it does, we
      -- try to fetch the organize imports action,
      -- and if it is supported, we apply it.
      if client:supports_method(ms.textDocument_codeAction, buf) then
        -- NOTE: Do not allow async formatting if we do
        -- sync organize imports first
        opts.async = false

        ---@diagnostic disable-next-line
        params.context = {
          only = { "source.organizeImports" },
          diagnostics = {},
        }
        local ns_push = vim.lsp.diagnostic.get_namespace(client.id, false)
        local ns_pull = vim.lsp.diagnostic.get_namespace(client.id, true)
        local diagnostics = {}
        local lnum = vim.api.nvim_win_get_cursor(win)[1] - 1
        vim.list_extend(
          diagnostics,
          vim.diagnostic.get(buf, { namespace = ns_pull, lnum = lnum })
        )
        vim.list_extend(
          diagnostics,
          vim.diagnostic.get(buf, { namespace = ns_push, lnum = lnum })
        )
        params.context.diagnostics = vim.tbl_map(
          function(d) return d.user_data.lsp end,
          diagnostics
        )
        local result = client:request_sync(
          ms.textDocument_codeAction,
          params,
          opts.timeout_ms,
          buf
        )
        if type(result) == "table" and type(result.result) == "table" then
          for _, r in pairs(result.result) do
            if not r.edit and client:supports_method(ms.codeAction_resolve) then
              -- NOTE: The action did not directly return
              -- the edit section, so we first try to resolve it,
              -- to determine what should be edited
              local new_result = client:request_sync(
                ms.codeAction_resolve,
                r,
                opts.timeout_ms,
                buf
              )
              if
                type(new_result) == "table"
                and type(new_result.result) == "table"
                and new_result.result.edit
              then
                vim.lsp.util.apply_workspace_edit(new_result.result.edit, enc)
              end
            else
              if r.edit then vim.lsp.util.apply_workspace_edit(r.edit, enc) end
            end
          end
        end
      end
    end
  end
  format(opts)
  show_dbg_message("Formatted with: " .. table.concat(client_names, ", "))
end

show_dbg_message = function(message)
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
