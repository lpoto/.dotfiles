--=============================================================================
-------------------------------------------------------------------------------
--                                                                       MAPPER
--=============================================================================
-- This module provides a simple interface for mapping keys to values and
-- checking if keys are already mapped. This is useful for making sure
-- there are no duplicate or overriding mappings.

local M = {}

---Map the provided lhs to rhs. If lhs is already mapped,
---this will log a warn and not map, unless force=true paramater
---is provided.
---If opts are not provided, {noremap=true} will be used as default.
---
---@param mode string
---@param lhs string
---@param rhs string
---@param opts table?
---@param force boolean?
function M.map(mode, lhs, rhs, opts, force)
  force = force or false
  opts = opts or { noremap = true }
  if not force then
    local rhs2 = vim.fn.mapcheck(lhs, mode)
    if
      type(rhs2) == "string"
      and rhs2 ~= ""
      and rhs2:find "packer.load" == nil
    then
      vim.notify(
        "Key already mapped: " .. lhs .. " -> " .. rhs2,
        vim.log.levels.WARN
      )
      return
    end
  end
  local ok, e = pcall(vim.api.nvim_set_keymap, mode, lhs, rhs, opts)
  if ok == false then
    vim.notify(
      "Error mapping key (" .. lhs .. "): " .. e,
      vim.log.levels.EROR
    )
  end
end

---Create a user command with the provided name, command, and options.
---Ihis will log a warn if the command already exists, unless force=true
---is provided.
---
---@param name string
---@param cmd function|string
---@param opts table?
---@param force boolean?
function M.command(name, cmd, opts, force)
  force = force or false
  opts = opts or {}
  if not force and vim.fn.exists(":" .. name) ~= 0 then
    vim.notify("Command already exists: " .. name, vim.log.levels.WARN)
    return
  end
  local ok, e = pcall(vim.api.nvim_create_user_command, name, cmd, opts)
  if ok == false then
    vim.notify(
      "Error creating command (" .. name .. "): " .. e,
      vim.log.levels.ERROR
    )
  end
end

return M
