--=============================================================================
--                                         https://github.com/kndndrj/nvim-dbee
--[[===========================================================================

Commands:
  :DBee (or :Dbee) - Open the DBEE drawer

NOTE: Also registers a dbee cmp source when the drawer opens

-----------------------------------------------------------------------------]]

local M = {
  "kndndrj/nvim-dbee",
  tag = "v0.1.6",
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "MattiasMTS/cmp-dbee",
    },
  },
  cmd = { "DBee", "Dbee" },
}

function M.build() require "dbee".install() end

function M.config()
  local config = require "dbee.config".default
  local candies = config.drawer.candies
  for k, v in pairs(candies) do
    if vim.tbl_contains({ "add", "edit", "remove" }, k) then
      v.icon = "·"
    else
      v.icon = ""
    end
  end

  local dbee = require "dbee";
  local dbee_open = dbee.open;
  ---@diagnostic disable-next-line: duplicate-set-field
  dbee.open = function()
    dbee_open()
    -- NOTE: Set up cmp completion after
    -- opening dbee
    local ok, cmp = pcall(require, "cmp")
    if ok then
      require "cmp-dbee".setup()
      local cmp_config = cmp.get_config()
      local sources = cmp_config.sources or {}
      for _, v in ipairs(sources) do
        if v.name == "cmp-dbee" then
          return
        end
      end
      table.insert(sources, { name = "cmp-dbee" })
      cmp_config.sources = sources
    end
  end

  dbee.setup {
    sources = {
      require "dbee.sources".FileSource:new(
        vim.fn.stdpath "data" .. "/dbee/persistence.json"
      ),
    },
    result = {
      page_size = 25,
    },
    drawer = {
      disable_help = true,
    },
    window_layout = require "dbee.layouts".Default:new {
      result_height = 28,
      drawer_width = 50,
      call_log_height = 10,
    },
  }
  for _, v in ipairs(M.cmd or {}) do
    vim.api.nvim_create_user_command(
      v,
      function() dbee.open() end,
      {}
    )
  end
end

return M
