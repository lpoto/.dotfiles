--=============================================================================
-------------------------------------------------------------------------------
--                                                                   MASON.NVIM
--[[===========================================================================
https://github.com/williamboman/mason.nvim

Package manager for neovim.
Easily install and manage lsp servers, linters and formatters.

Commands:
  - :Mason                    - Open a graphical status window
  - :MasonInstall <package>   - Install/reinstalls a package
  - :MasonUninstall <package> - Uninstalls a package
  - :MasonUninstallAll        - Uninstalls all packages
  - :MasonLog                 - Open the log file
-----------------------------------------------------------------------------]]
return {
  "williamboman/mason.nvim",
  lazy = false,
  -- Don't set it as optional so the path to installed binaries
  -- is added to the PATH environment variable on startup.
  config = function()
    Util.require("mason", function(mason)
      mason.setup()
    end)
  end,
}
