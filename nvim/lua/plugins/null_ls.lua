--=============================================================================
-------------------------------------------------------------------------------
--                                                                 NULL-LS.NVIM
--[[===========================================================================
https://github.com/nvimtools/none-ls.nvim
-----------------------------------------------------------------------------]]

local M = {
  "nvimtools/none-ls.nvim",
}

local init_null_ls
vim.lsp.add_attach_condition({
  priority = 25,
  fn = function(opts)
    local null_ls = require("null-ls")
    local source = nil
    for _, k in ipairs({ "formatting", "diagnostics", "completion" }) do
      local ok = pcall(require, "null-ls.builtins." .. k .. "." .. opts.name)
      if ok then
        source = null_ls.builtins[k][opts.name]
        if source then break end
      end
    end
    if not source then return {
      missing = { opts.name },
    } end
    if
      type(source) == "table"
      and type(source._opts) == "table"
      and type(source._opts.command) == "string"
    then
      if
        vim.fn.executable(
          vim.trim(vim.fn.split(vim.trim(source._opts.command), " ")[1])
        ) ~= 1
      then
        return {
          non_executable = { opts.name },
        }
      end
    end
    require("null-ls.sources").register({
      sources = { source },
    })
    init_null_ls()
    return { attached = { opts.name } }
  end,
})

local did_init = false
function init_null_ls()
  if did_init then return end
  did_init = true
  vim.api.nvim_create_autocmd("Filetype", {
    callback = function(opts)
      vim.defer_fn(function()
        if
          type(opts) ~= "table"
          or type(opts.match) ~= "string"
          or type(opts.buf) ~= "number"
        then
          return
        end
        local client_id = require("null-ls.client").get_id()
        if type(client_id) ~= "number" then return end
        local a = require("null-ls.sources").get_filetypes()
        if not vim.tbl_contains(a, opts.match) then return end
        vim.lsp.buf_attach_client(opts.buf, client_id)
      end, 10)
    end,
  })
end

vim.lsp.buf.update_format_opts = function(opts)
  if not package.loaded["null-ls"] then return opts end
  if
    type(opts.bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(opts.bufnr)
  then
    opts.bufnr = vim.api.nvim_get_current_buf()
  end
  local mode = vim.fn.mode():lower()
  local method = nil
  if vim.startswith(mode, "n") then
    method = require("null-ls.methods").internal.FORMATTING
  elseif vim.startswith(mode, "v") then
    method = require("null-ls.methods").internal.RANGE_FORMATTING
  else
    return opts
  end
  local filetype = vim.api.nvim_buf_get_option(opts.bufnr, "filetype")
  local available = require("null-ls.sources").get_available(filetype, method)
  if next(available or {}) then
    local names = vim.tbl_filter(
      function(o) return type(o) == "table" and type(o.name) == "string" end,
      available
    )
    names = vim.tbl_map(function(o) return o.name end, names)
    opts.name = "null-ls"
    opts.filter = function(client)
      return type(client) == "table" and client.name == opts.name
    end
    opts.callback = function()
      if next(names) then
        vim.defer_fn(function()
          if type(vim.g.display_message) == "function" then
            vim.g.display_message({
              message = "formatted with: " .. table.concat(names, ", "),
              title = "null-ls",
            })
          else
            vim.notify(
              "formatted with: " .. table.concat(names, ", "),
              vim.log.levels.DEBUG,
              {
                title = "null-ls",
              }
            )
          end
        end, 100)
      end
    end
  end
  return opts
end

return M
