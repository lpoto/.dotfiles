--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM AUTOPAIRS
--=============================================================================
-- https://github.com/windwp/nvim-autopairs
--_____________________________________________________________________________

local M = {
  "windwp/nvim-autopairs",
}

function M.init()
  local id
  id = vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
      if buftype:len() == 0 then
        vim.api.nvim_del_autocmd(id)
        M.config()
      end
    end,
  })
end

function M.config()
  local cmp = require "cmp"
  local npairs = require "nvim-autopairs"
  local cmp_autopairs = require "nvim-autopairs.completion.cmp"
  local ts_conds = require "nvim-autopairs.ts-conds"
  local Rule = require "nvim-autopairs.rule"

  cmp.event:on(
    "confirm_done",
    cmp_autopairs.on_confirm_done { map_char = { tex = "" } }
  )
  npairs.setup {
    check_ts = true,
  }
  npairs.add_rules {
    Rule("%", "%", "lua"):with_pair(
      ts_conds.is_ts_node { "string", "comment" }
    ),
    Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node { "function" }),
  }
end

return M
