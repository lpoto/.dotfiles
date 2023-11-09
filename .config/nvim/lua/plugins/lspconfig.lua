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

function M.config()
  require 'lspconfig.ui.windows'.default_options.border = 'single'
end

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

return M
