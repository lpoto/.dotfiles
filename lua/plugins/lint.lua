--=============================================================================
-------------------------------------------------------------------------------
--                                                                    NVIM-LINT
--=============================================================================
-- https://github.com/mfussenegger/nvim-lint
--_____________________________________________________________________________

local lint = require("util.packer_wrapper").get "lint"

---Default setup for nvim-lint.
---Create autocmd that lints on save.
lint:config(function()
  local log = require "util.log"
  local lint_module = require "lint"

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
      local ok, e = pcall(vim.fn.execute, "lua require('lint').try_lint()")
      if ok == false then
        log.warn("nvim-lint: " .. e)
      end
    end,
  })

  if lint_module.linters_by_ft == nil then
    lint_module.linters_by_ft = {}
  end
end)
