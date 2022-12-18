--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PACKER
--=============================================================================
-- https://github.com/wbthomason/packer.nvim
--_____________________________________________________________________________
-- This loads all the plugins defined in other config files,
-- example  in /plugin.
--
-- If packer is not installed, this will install it and compile plugins.
------------------------------------------------------------------------------

local log = require "log"

---Ensure that packer.nvim package exists, if it does
---not, install it.
---@return function?: Function to run on startup
---@return boolean: Whether packer is available
local function ensure_packer()
  local install_path = vim.fn.stdpath "data"
    .. "/site/pack/packer/opt/packer.nvim"

  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    log.warn "Packer.nvim not found!"
    local choice =
      vim.fn.confirm("Do you want to install it?", "&Yes\n&No", 2)

    if choice ~= 1 then
      return nil, false
    end

    log.debug "Installing Packer.nvim ..."

    local args = {
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path,
    }

    log.info("Running: " .. table.concat(args, " "))

    vim.fn.system(args)

    log.info "Packer.nvim installed"

    return function()
      require("packer").sync()
    end, true
  end
  return nil, true
end

---Load all plugins with Packer.nvim. Make sure that Packer.nvim
---is installed before loading plugins.
---If it is not installed, install it and compile plugins.
local function packer_startup()
  local packer_bootstrap, ok = ensure_packer()
  if not ok then
    log.warn "Packer.nvim not available, not loading plugins"
    return
  end

  vim.api.nvim_exec("packadd packer.nvim", true)

  --NOTE: add all the required plugins with the packer
  require("packer").startup {
    function(use)
      -- add packer as it's own package, so it is in opt not start directory,
      -- otherwise it tried to remove itself
      use { "wbthomason/packer.nvim", opt = true }

      -- Add all the plugins defined in other config files.
      require("plugin").use(use)

      if packer_bootstrap ~= nil then
        packer_bootstrap()
      end
    end,
    config = {
      -- NOTE: compile packer to after, so plugins
      -- are loaded after other default configs
      compile_path = require("packer.util").join_paths(
        vim.fn.stdpath "config",
        "after",
        "plugin",
        "packer_compiled.lua"
      ),
      -- Display packer actions in a float
      display = {
        open_fn = function()
          return require("packer.util").float { border = "single" }
        end,
      },
    },
  }
end

packer_startup()
