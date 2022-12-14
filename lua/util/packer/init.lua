--=============================================================================
-------------------------------------------------------------------------------
--                                                                  PACKER.NVIM
--=============================================================================
-- https://github.com/wbthomason/packer.nvim
-------------------------------------------------------------------------------

local M = {}

local ensure_packer

---Call the Packer.nvim startup function and
---ensure the packer exists.
---
---@param f function
function M.startup(f)
  local packer = ensure_packer()
  if packer == nil then
    return
  end

  --NOTE: add all the required plugins with the packer

  packer.startup(f)
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

return M
