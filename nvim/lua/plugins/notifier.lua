--=============================================================================
-------------------------------------------------------------------------------
--                                                                NOTIFIER.NVIM
--[[===========================================================================
https://github.com/vigoux/notifier.nvim

A plugin that overrides vim.notify and lsp progress bars
-----------------------------------------------------------------------------]]
local M = {
  "vigoux/notifier.nvim",
  event = "BufEnter",
  opts = {
    notify = {
      min_level = Util.log().level,
    },
  },
}

return M
