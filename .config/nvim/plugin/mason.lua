--=============================================================================
--                                                                        MASON
--[[===========================================================================

Mason is a package manager that allows you to easily install and manage
external tools such as LSP servers, linters, ...

NOTE: Installs into its own directory (stdpath("data")/mason), and
adds them to path on startup,
so the binaries are always available inside Neovim.

Relevant commands:
- :Mason     (mason window)

-----------------------------------------------------------------------------]]

local config = {
  src = "https://github.com/williamboman/mason.nvim",
  version = "v2.2.1"
}

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("PackChanged_Mason", { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-mason" and (kind == "update" or kind == "install") then
      vim.cmd "MasonUpdate"
    end
  end
})

vim.pack.add { config }

require "mason".setup()
