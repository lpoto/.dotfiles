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

--- NOTE: Override default lsp format to
--- perform organize imports action before formatting
local format_util = {}

format_util.format = vim.lsp.buf.format
format_util.skip_organize_imports_clients = { "lua_ls" }

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

  -- NOTE: First try to organize imports, and then
  -- format regardless of the results of organize imports action
  format_util.organize_imports(
    clients,
    method,
    opts,
    function()
      format_util.format(opts)

      format_util.show_dbg_message("Formatted with: " ..
        table.concat(client_names, ", "))
    end)
end

---@param clients vim.lsp.Client[]
---@param method string
---@param opts table
---@param callback function
function format_util.organize_imports(clients, method, opts, callback)
  local ms = require "vim.lsp.protocol".Methods
  local buf = opts.bufnr or vim.api.nvim_get_current_buf()
  local win = vim.fn.bufwinid(buf)

  local mode = vim.api.nvim_get_mode().mode
  if mode ~= "n" or method ~= ms.textDocument_formatting then
    return callback()
  end
  for _, client in ipairs(clients) do
    local enc = client.offset_encoding or "utf-16"
    local params = vim.lsp.util.make_range_params(win, enc)
    -- NOTE: We first check if client even supports
    -- fetching code actions, if it does, we
    -- try to fetch the organize imports action,
    -- and if it is supported, we apply it.
    if
      (type(format_util.skip_organize_imports_clients) ~= "table"
        or not vim.tbl_contains(format_util.skip_organize_imports_clients, client.name))
      and client:supports_method(ms.textDocument_codeAction, buf) then
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
      client:request(
        ms.textDocument_codeAction,
        params,
        function(err, result)
          local res = result and (result.result or result)
          if err
            or type(res) ~= "table" then
            return callback()
          end
          for _, r in pairs(res) do
            if not r.edit and client:supports_method(ms.codeAction_resolve) then
              -- NOTE: The action did not directly return
              -- the edit section, so we first try to resolve it,
              -- to determine what should be edited
              client:request(
                ms.codeAction_resolve,
                r,
                function(new_err, new_result)
                  local new_res = new_result and
                    (new_result.result or new_result)
                  if
                    not new_err
                    and type(new_result.edit) == "table"
                  then
                    vim.lsp.util.apply_workspace_edit(new_res.edit, enc)
                    format_util.show_dbg_message(
                      "Organized imports with: " .. client.name)
                  end
                  callback()
                end,
                buf
              )
              return
            elseif type(r.edit) == "table" then
              vim.lsp.util.apply_workspace_edit(r.edit, enc)
              format_util.show_dbg_message(
                "Organized imports with: " .. client.name)
              callback()
              return
            end
          end
          callback()
        end,
        buf
      )
      return
    end
  end
  callback()
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
