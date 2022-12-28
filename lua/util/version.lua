--=============================================================================
-------------------------------------------------------------------------------
--                                                                      VERSION
--=============================================================================
-- Extract the neovim version
--_____________________________________________________________________________

local M = {}

M.required_version = "nvim-0.9"

---@return string: the version of neovim
function M.get()
  local version = vim.version()

  local s = version.major
  s = s .. "." .. version.minor
  s = s .. "." .. version.patch
  if version.prerelease then
    s = s .. " (prerelease)"
  end
  return s
end

---@return boolean: Whether the current version is sufficient for
---the configuration to run.
function M.check()
  return vim.fn.has(M.required_version) == 1
end

---Ensures the version is valid for the configuration to run,
---and warns the user if it is not.
function M.ensure()
  if M.check() ~= true then
    vim.notify(
      "For this configuration to run properly, "
        .. "version "
        .. M.required_version
        .. " or higher is required.",
      vim.log.levels.WARN,
      { title = "Version" }
    )
  end
end

return M
