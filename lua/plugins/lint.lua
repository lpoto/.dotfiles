--=============================================================================
-------------------------------------------------------------------------------
--                                                                    NVIM-LINT
--=============================================================================
-- https://github.com/mfussenegger/nvim-lint
--_____________________________________________________________________________

local log = require "util.log"

local added_linters = {}

local M = {}

---Default setup for nvim-lint.
---@param autocmd boolean?: when true, ties linting on save
function M.init(autocmd)
  local lint = require "lint"
  if autocmd == true then
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        local ok, e = pcall(vim.fn.execute, "lua require('lint').try_lint()")
        if ok == false then
          log.warn("nvim-lint: " .. e)
        end
      end,
    })
  end
  lint.linters_by_ft = added_linters
end

---Add linters for a filetype. If lint plugin was already loaded they
---will be registered immediately, else when the plugin is loaded.
---
---@param filetype string: A valid filetype. Ex. 'markdown'.
---@param linters table: A table of linters. Ex: {'vale',}.
---@param load boolean?: Load plugin if not yet loaded
function M.add_linters(filetype, linters, load)
  added_linters[filetype] = linters

  if load == true or package.loaded["lint"] ~= nil then
    local lint = require "lint"
    lint.liters_by_ft = added_linters
    return
  end
end

return M
