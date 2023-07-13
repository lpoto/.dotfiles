--=============================================================================
-------------------------------------------------------------------------------
--                                                                    NVIM-LINT
--[[===========================================================================
https://github.com/mfussenegger/nvim-lint

-----------------------------------------------------------------------------]]
local M = {
  "mfussenegger/nvim-lint",
}

function M.config()
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = vim.api.nvim_create_augroup("Lint", { clear = true }),
    callback = function()
      Util.require({ "lint" }, function(lint)
        local linters = (lint.linters_by_ft or {})[vim.bo.filetype] or {}
        if #linters == 0 then
          return
        end
        if #linters == 1 then
          Util.log():debug("Linting with:", linters[1])
        else
          Util.log():debug("Linting with:", linters)
        end

        lint.try_lint()
      end)
    end,
  })
end

---Override the util's default attach linter function.
---
---@param linter string
---@param filetype string
---@diagnostic disable-next-line: duplicate-set-field
Util.misc().attach_linter = function(linter, filetype)
  if type(filetype) ~= "string" then
    Util.log():warn("Invalid filetype for linter:", filetype)
    return
  end
  if type(linter) ~= "string" then
    Util.log():warn("Invalid linter:", linter)
    return
  end
  Util.require("lint", function(lint)
    if type(lint.linters_by_ft) ~= "table" then
      lint.linters_by_ft = {}
    end
    if type(lint.linters_by_ft[filetype]) ~= "table" then
      lint.linters_by_ft[filetype] = {}
    end
    table.insert(lint.linters_by_ft[filetype], linter)
    Util.log():debug("Attached linter for " .. filetype .. ":", linter)
  end)
end

return M
