--=============================================================================
--                                         https://github.com/kndndrj/nvim-dbee
--[[===========================================================================

Commands:
  :DBee (or :Dbee) - Open the DBEE drawer
-----------------------------------------------------------------------------]]

local M = {
  "kndndrj/nvim-dbee",
  tag = "v0.1.2",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  cmd = { "DBee", "Dbee" },
}

function M.build() require("dbee").install() end

local layout = {}

function M.config()
  local config = require("dbee.config").default
  local candies = config.drawer.candies
  for k, v in pairs(candies) do
    if vim.tbl_contains({ "add", "edit", "remove" }, k) then
      v.icon = "·"
    else
      v.icon = ""
    end
  end
  require("dbee").setup {
    result = {
      page_size = 20,
    },
    window_layout = layout,
  }
  for _, v in ipairs(M.cmd or {}) do
    vim.api.nvim_create_user_command(
      v,
      function() require("dbee").open() end,
      {}
    )
  end
end

function layout:new()
  local o = {
    egg = nil,
    windows = {},
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function layout:open(uis)
  local tools = require "dbee.layouts.tools"
  self.egg = tools.save()
  self.windows = {}
  tools.make_only(0)
  local editor_win = vim.api.nvim_get_current_win()
  table.insert(self.windows, editor_win)
  uis.editor:show(editor_win)
  vim.cmd "bo 23split"
  local win = vim.api.nvim_get_current_win()
  table.insert(self.windows, win)
  uis.result:show(win)
  vim.cmd "to 50vsplit"
  win = vim.api.nvim_get_current_win()
  table.insert(self.windows, win)
  uis.drawer:show(win)
  vim.cmd "belowright 10split"
  win = vim.api.nvim_get_current_win()
  table.insert(self.windows, win)
  uis.call_log:show(win)
  vim.api.nvim_set_current_win(editor_win)
end

function layout:close()
  local tools = require "dbee.layouts.tools"
  for _, win in ipairs(self.windows) do
    pcall(vim.api.nvim_win_close, win, false)
  end
  tools.restore(self.egg)
  self.egg = nil
end

return M
