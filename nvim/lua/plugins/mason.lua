--=============================================================================
-------------------------------------------------------------------------------
--                                                                   MASON.NVIM
--[[===========================================================================
https://github.com/williamboman/mason.nvim

Package manager for neovim.
Easily install and manage lsp servers and formatters.

Commands:
  - :Mason                    - Open a graphical status window
  - :MasonInstall <package>   - Install/reinstalls a package
  - :MasonUninstall <package> - Uninstalls a package
  - :MasonUninstallAll        - Uninstalls all packages
  - :MasonLog                 - Open the log file
-----------------------------------------------------------------------------]]
local M = {
  "williamboman/mason.nvim",
  -- NOTE: Don't set it as optional so the path to installed binaries
  -- is added to the PATH environment variable on startup.
  lazy = false,
}

function M.config()
  Util.require(
    "mason",
    function(mason)
      mason.setup({
        ui = { border = "rounded" },
      })
    end
  )
end

Util.setup["mason"] = function()
  vim.api.nvim_exec2("MasonUpdate", {})
  vim.api.nvim_exec2("MasonInstall efm", {})
end

return M
