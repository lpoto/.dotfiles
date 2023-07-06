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
local M = {
  "williamboman/mason.nvim",
  -- NOTE: Don't set it as optional so the path to installed binaries
  -- is added to the PATH environment variable on startup.
  lazy = false,
  dependencies = {
    "jay-babu/mason-null-ls.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
}

function M.config()
  Util.require(
    { "mason", "mason-core.installer", "mason-core.async" },
    function(mason, installer, async)
      mason.setup({
        ui = { border = "rounded" },
      })
      local installer_execute = installer.execute
      installer.execute = function(handle, opts)
        async.wait_all({
          function()
            return installer_execute(handle, opts)
          end,
        })
      end
    end
  )
end

---@param server string
local function ensure_language_server_installed(server)
  Util.require("mason-lspconfig", function(mason)
    mason.setup({
      ensure_installed = { server },
    })
  end)
end

---@param source string
local function ensure_null_ls_source_intalled(source)
  Util.require("mason-null-ls", function(mason)
    mason.setup({
      ensure_installed = { source },
    })
  end)
end

---Override the default ensure_source_installed function, so
---we can automatically install missing language servers, formatters,
---linters,...
---@param source_type string
---@param source string
---@diagnostic disable-next-line: duplicate-set-field
Util.misc().ensure_source_installed = function(source_type, source)
  if type(source) ~= "string" then
    Util.log():warn("Invalid source: ", source)
    return
  end
  if
    type(source_type) == "string"
    and (source_type:match("lsp") or source_type:match("server"))
  then
    return ensure_language_server_installed(source)
  end
  return ensure_null_ls_source_intalled(source)
end

return M
