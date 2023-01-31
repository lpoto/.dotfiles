--=============================================================================
-------------------------------------------------------------------------------
--                                                                 NULL-LS.NVIM
--=============================================================================
-- https://github.com/jose-elias-alvarez/null-ls.nvim
--_____________________________________________________________________________

--[[
Injects lsp diagnostics, code actions, formatting,...

Keymaps:
  - <leader>f  - Format current file and save

Commands:
  - :NullLsInfo - Show information about the current null-ls session
  - :NullLsLog  - Open the log file
--]]

local M = {
  "jose-elias-alvarez/null-ls.nvim",
  cmd = { "NullLsInfo", "NullLsLog" },
}

M.keys = {
  {
    "<leader>f",
    function()
      require("plugins.null-ls").format()
    end,
    mode = "n",
  },
}

function M.config()
  local null_ls = require "null-ls"

  null_ls.setup()
end

function M.format()
  local ok, e = pcall(function()
    vim.lsp.buf.format {
      timeout_ms = 10000,
      async = false,
    }
  end)
  if not ok and type(e) == "string" then
    vim.notify(e, vim.log.levels.WARN, {
      title = "Format",
    })
  end
end

---@param opts string|table
function M.register_formatter(opts)
  M.register_builtin_source("formatting", opts)
end

---@param opts string|table
function M.register_linter(opts)
  M.register_builtin_source("diagnostics", opts)
end

local expand_opts
---@param type string
---@param opts string|table
function M.register_builtin_source(type, opts)
  opts = expand_opts(opts)
  local ok, e = pcall(function()
    local null_ls = require "null-ls"
    local s = null_ls.builtins[type][opts.source]
    if not s then
      vim.notify(
        "No such builtin source: " .. opts.source,
        vim.log.levels.WARN,
        {
          title = "NullLs",
        }
      )
      return
    end
    if opts.config and next(opts.config) then
      s = s.with(opts.config)
    end
    null_ls.register {
      filetypes = { opts.filetype },
      sources = { s },
    }
  end)
  if not ok and type(e) == "string" then
    vim.notify(e, vim.log.levels.ERROR, {
      title = "NullLs",
    })
  end
end

expand_opts = function(opts)
  if type(opts) == "string" then
    return {
      source = opts,
      filetype = vim.bo.filetype,
    }
  end
  opts.filetype = opts.filetype or vim.bo.filetype
  return opts
end

return M
