--=============================================================================
-------------------------------------------------------------------------------
--                                                                      VERSION
--=============================================================================
-- Extract the neovim version and warn when the version is too low.
--_____________________________________________________________________________

local M = {
  dir = table.concat(
    { vim.fn.stdpath "config", "lua", "plugins", "version" },
    "/"
  ),
  event = "VeryLazy",
}

function M.config()
  local version = require "version"
  version.required_version = "nvim-0.9"
  version.required_os = { "linux", "macos", "darwin" }
end

function M.init()
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
      local version = require "version"
      version.ensure(true, true)
    end,
  })
end

return M
