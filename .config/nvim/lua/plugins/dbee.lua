--=============================================================================
--                                         https://github.com/kndndrj/nvim-dbee
--[[===========================================================================

Commands:
  :DBee (or :Dbee) - Open the DBEE drawer

NOTE: Also registers a dbee cmp source when the drawer opens

-----------------------------------------------------------------------------]]

local M = {
  "kndndrj/nvim-dbee",
  tag = "v0.1.9",
  dependencies = {
    { "MunifTanjim/nui.nvim", tag = "0.3.0" },
    {
      "MattiasMTS/cmp-dbee",
      commit = "1650f67",
      opts = {}
    },
  },
  cmd = { "DBee", "Dbee" },
}

function M.build() require "dbee".install() end

function M.config()
  local dbee = require "dbee"
  local sources = require "dbee.sources"
  local layouts = require "dbee.layouts"

  ---@diagnostic disable-next-line
  dbee.setup {
    sources = {
      sources.FileSource:new(
        vim.fn.stdpath "data" .. "/dbee/persistence.json"
      ),
    },
    result = {
      page_size = 25,
    },
    drawer = {
      disable_help = true,
    },
    window_layout = layouts.Default:new {
      result_height = 28,
      drawer_width = 50,
      call_log_height = 10,
    },
  }
  for _, v in ipairs(M.cmd or {}) do
    vim.api.nvim_create_user_command(v, function() dbee.open() end, {})
  end

  -- NOTE: Add the dbee cmp source to blink.cmp,
  -- so we get autocompletion for schema and queries
  local has_cmp, cmp = pcall(require, "blink.cmp")
  if has_cmp then
    cmp.add_source_provider("dbee", {
      name = "cmp-dbee",
      module = "blink.compat.source",
      -- NOTE: Enable this source only when dbee is open
      enabled = dbee.is_open
    })
    cmp.add_filetype_source("sql", "dbee")
  end
end

return M
