--=============================================================================
--                                   https://github.com/williamboman/mason.nvim
--[[===========================================================================

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
  "mason-org/mason.nvim",
  tag = "v2.2.1",
  -- NOTE: Don't set it as optional so the path to installed binaries
  -- is added to the PATH environment variable on startup.
  lazy = false,
  priority = 1000,
  opts = {}
}

function M.build() vim.cmd "MasonUpdate" end

return M
