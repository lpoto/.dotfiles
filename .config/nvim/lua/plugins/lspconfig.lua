--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-LSPCONFIG
--[[===========================================================================
https://github.com/neovim/nvim-lspconfig
-----------------------------------------------------------------------------]]

local M = {
  'neovim/nvim-lspconfig',
  cmd = { 'LspInfo', 'LspStart', 'LspLog' },
}

local root_fn
vim.lsp.add_attach_condition {
  priority = 50,
  fn = function(server, bufnr)
    local ok, _ =
      pcall(require, 'lspconfig.server_configurations.' .. server.name)
    if not ok then
      return {
        missing = { server.name },
      }
    end
    local lsp = require 'lspconfig'[server.name]
    if lsp == nil then
      return {
        missing = { server.name },
      }
    end

    server.autostart = true
    if server.capabilities == nil then
      local has_cmp, cmp = pcall(require, 'cmp_nvim_lsp')
      if has_cmp then server.capabilities = cmp.default_capabilities() end
    end
    if server.root_dir == nil and type(server.root_patterns) == 'table' then
      server.root_dir = root_fn(server.root_patterns)
    end

    lsp.setup(server)
    local config = require 'lspconfig.configs'[server.name]
    if type(config) ~= 'table' then return { missing = { server.name } } end
    local cmd = config.cmd
    local executable = nil
    if type(cmd) == 'table' and #cmd > 0 then
      executable = cmd[1]
    elseif type(cmd) == 'string' and cmd:len() > 0 then
      executable = cmd:gsub('^%s*(.-)%s*$', '%1')
      executable = vim.fn.split(executable)[1]
    end
    local ret = {}
    if executable ~= nil and vim.fn.executable(executable) ~= 1 then
      ret.non_executable = { server.name }
    end
    config.launch(bufnr)
    ret.attached = { server.name }
    return ret
  end,
}

function root_fn(patterns, default, opts)
  return function()
    if type(opts) ~= 'table' then opts = {} end
    if type(opts.path) ~= 'string' then opts.path = vim.fn.expand '%:p:h' end
    local f = nil
    if type(patterns) == 'table' and next(patterns) then
      f = vim.fs.find(
        patterns,
        vim.tbl_extend('force', { upward = true }, opts)
      )
    end
    if type(f) ~= 'table' or not next(f) then
      if type(default) == 'string' then return default end
      return vim.fn.getcwd()
    end
    return vim.fs.dirname(f[1])
  end
end

return M
