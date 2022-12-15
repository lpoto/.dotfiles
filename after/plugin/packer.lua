--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PACKER
--=============================================================================
-- https://github.com/wbthomason/packer.nvim
--_____________________________________________________________________________

local log = require "log"

local plugins = {}

local ensure_packer

---Manually load the packer.nvim package and use it
---to load all the required plugins.
function plugins.setup()
  --NOTE: make sure the packer.nvim is available, if not, install it
  local packer = ensure_packer()
  if packer == nil then
    return
  end

  local util = require "packer.util"
  packer.init {
    compile_path = util.join_paths(
      vim.fn.stdpath "config",
      "after",
      "plugin",
      "packer_compiled.lua"
    ),
  }

  --NOTE: add all the required plugins with the packer
  packer.startup(function(use)
    -- add packer as it's own package, so it is in opt not start directory,
    -- otherwise it tried to remove itself
    use { "wbthomason/packer.nvim", opt = true }

    require("plugin").use(use)
  end)
end

---Ensure that packer.nvim package exists, if it does
---not, install it.
---@return table?
ensure_packer = function()
  vim.api.nvim_exec("packadd packer.nvim", false)

  local ok, packer = pcall(require, "packer")

  if ok == true then
    return packer
  end

  local install_path = vim.fn.stdpath "data"
    .. "/site/pack/packer/start/packer.nvim"

  log.info "Installing packer.nvim"

  ok, packer = pcall(vim.fn.system, {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  if ok == false then
    log.error(packer)
    return nil
  end
  vim.api.nvim_exec("packadd packer.nvim", false)
  return require "packer"
end

plugins.setup()
