--=============================================================================
-------------------------------------------------------------------------------
--                                                                   MASON.NVIM
--=============================================================================
-- https://github.com/williamboman/mason.nvim
--_____________________________________________________________________________

--[[
Package manager for neovim.
Easily install and manage lsp servers, dap servers, linters and formatters.

Commands:
  - :Mason                    - Open a graphical status window
  - :MasonInstall <package>   - Install/reinstalls a package
  - :MasonUninstall <package> - Uninstalls a package
  - :MasonUninstallAll        - Uninstalls all packages
  - :MasonLog                 - Open the log file
--]]

require("plugin").new {
  "williamboman/mason.nvim",
  as = "mason",
  -- Don't set it as optional so the path to installed binaries
  -- is added to the PATH environment variable on startup.
  config = function()
    local mason = require "mason"
    mason.setup()
  end,
}
