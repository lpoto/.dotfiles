--=============================================================================
-------------------------------------------------------------------------------
--                                                                      VERSION
--=============================================================================
-- Extract the neovim version
--_____________________________________________________________________________

local M = {}

M.required_version = "nvim-0.9"
M.required_os = { "linux", "macos", "darwin" }

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

---Ensures the version and os are valid for the configuration to run,
---and warns the user if it is not.
---@param ensure_version boolean: Ensure version and warn when not sufficient
---@param ensure_os boolean: Ensure os and warn when not linux or macos
function M.ensure(ensure_version, ensure_os)
  if ensure_version and M.check() ~= true then
    vim.notify(
      "For this configuration to run properly, "
        .. "version "
        .. M.required_version
        .. " or higher is required.",
      vim.log.levels.WARN,
      { title = "Version" }
    )
  end
  if
    ensure_os
    and vim.tbl_contains(
        M.required_os,
        string.lower(vim.loop.os_uname().sysname)
      )
      ~= true
  then
    vim.notify(
      "For this configuration to run properly, "
        .. "the operating system must be one of: "
        .. table.concat(M.required_os, ", "),
      vim.log.levels.WARN,
      { title = "OS" }
    )
  end
end

return M
