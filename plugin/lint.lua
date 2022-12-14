--=============================================================================
-------------------------------------------------------------------------------
--                                                                    NVIM-LINT
--=============================================================================
-- https://github.com/mfussenegger/nvim-lint
--_____________________________________________________________________________

require("plugin").new {
  "mfussenegger/nvim-lint",
  as = "lint",
  module = "lint",
  config = function(lint)
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        local log = require "log"
        local ok, e = pcall(vim.fn.execute, "lua require('lint').try_lint()")
        if ok == false then
          log.warn("nvim-lint: " .. e)
        end
      end,
    })
    lint.linters_by_ft = {}
  end,
}
