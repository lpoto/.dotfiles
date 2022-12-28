--=============================================================================
-------------------------------------------------------------------------------
--                                                                      VERSION
--=============================================================================
-- Extract the neovim version
--_____________________________________________________________________________

local M = {}

---@return string: the version of neovim
function M.get()
  local version = vim.version()

  local s = version.major
  s = s .. "." .. version.minor
  s = s.. "." .. version.patch
  if version.prerelease then
    s = s .. " (prerelease)"
  end
  return s
end

---@return boolean: Whether the current version is sufficient for
---the configuration to run.
function M.check()
  return vim.fn.has("nvim-0.9") == 1
end

return M
