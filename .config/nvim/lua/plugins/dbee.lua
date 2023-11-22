--=============================================================================
--                                         https://github.com/kndndrj/nvim-dbee
--[[===========================================================================

Commands:
  :DB (or :Db) - Open the DBEE drawer
-----------------------------------------------------------------------------]]

local M = {
  'kndndrj/nvim-dbee',
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
  cmd = { 'DBee', 'Dbee' },
}

local util = {}

function M.build()
  require 'dbee'.install()
end

function M.config()
  local config = require 'dbee.config'.default
  local candies = config.drawer.candies
  for k, v in pairs(candies) do
    if vim.tbl_contains({ 'add', 'edit', 'remove' }, k) then
      v.icon = '·'
    else
      v.icon = ''
    end
  end
  util.set_up_dbee()
  for _, v in ipairs(M.cmd or {}) do
    vim.api.nvim_create_user_command(v, function()
      require 'dbee'.open()
    end, {})
  end
end

function util.set_up_dbee()
  if not util.__config then
    util.__config = require 'dbee.config'.default
    local sources = require 'dbee.sources'
    util.__config.sources = {
      sources.EnvSource:new 'DBEE_CONNECTIONS',
      sources.FileSource:new(vim.fn.stdpath 'data' .. '/dbee/persistence.json'),
    }

    local old_post_hook = util.__config.ui.post_open_hook
    local old_pre_hook = util.__config.ui.pre_open_hook
    util.__config.ui.post_open_hook = function()
      if type(old_post_hook) == 'function' then
        old_post_hook()
      end
      vim.wo.cursorline = true
    end
    util.__config.ui.pre_open_hook = function()
      util.set_up_dbee()
      if type(old_pre_hook) == 'function' then
        old_pre_hook()
      end
    end
  end
  local w = math.min(80, math.floor(vim.o.columns / 2.5))
  local h = math.min(28, math.floor(vim.o.lines / 2.5))

  local cfg = vim.tbl_deep_extend('force', util.__config, {
    ui = {
      window_commands = {
        drawer = 'to ' .. w .. 'vsplit',
        result = 'bo ' .. h .. 'split',
      }
    }
  })
  require 'dbee'.setup(cfg)
end

return M
