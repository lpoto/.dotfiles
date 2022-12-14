--=============================================================================
-------------------------------------------------------------------------------
--                                                                 LOCAL CONFIG
--=============================================================================
-- Store local project configs in .local/ directory.
-- Configs are saved based on the root of the currently oppened project and
-- the current machine's hostname.
-- Open/ add local configs with :LocalConfig
-- Remove them with :RemoveLocalConfig
--_____________________________________________________________________________

local log = require "util.log"
local root = require "util.root"()

local open_local_config
local remove_local_config

---NOTE: use :LocalConfig  command to open or create new
---project local config files, that will be saved in the .local directory.
vim.api.nvim_create_user_command("LocalConfig", function()
  open_local_config()
end, {})
---NOTE: use :RemoveLocalConfig  command to remove existing
---project local config files, be saved in the .local directory.
vim.api.nvim_create_user_command("RemoveLocalConfig", function()
  remove_local_config()
end, {})
---NOTE: use :SourceLocalConfig  command to source the local configs.
vim.api.nvim_create_user_command("LocalConfig", function()
  open_local_config()
end, {})

-------------------------------------------------------------------------------

---The defult path for the local config files
---@type string
local local_configs_path = vim.fn.stdpath "data" .. "/local_configs"
---The base of the local config files for the current host
---@type string
local base = local_configs_path .. "/" .. vim.fn.hostname() .. "/"

---@type number: Number of levels to check the local config for
local DEPTH = 3

---@param level number?: When 0 root is checked, else #level levels up
---@return string escaped path
---@return string unescaped path
---@return string root used for the path
local function get_path(level)
  local r = root
  for _ = 0, level - 1 do
    local l = vim.fs.dirname(r)
    if l == r then
      break
    end
    r = l
  end
  return base .. vim.fn.substitute(
    vim.fn.substitute(r, "\\", "\\\\%", "g"),
    "/",
    "\\\\%",
    "g"
  ),
    base .. vim.fn.substitute(
      vim.fn.substitute(r, "\\", "\\%", "g"),
      "/",
      "\\%",
      "g"
    ),
    r
end

---Opens local config for the currently oppened project.
---If it does not exist, it prompts the option to create it.
open_local_config = function()
  local file_escaped, file, r = get_path(0)
  file = file .. ".lua"
  file_escaped = file_escaped .. ".lua"
  if vim.fn.filereadable(file) ~= 1 then
    local f_h, f_he = nil, nil
    for i = 1, DEPTH - 1 do
      local r2
      f_he, f_h, r2 = get_path(i)
      if vim.fn.filereadable(f_h .. ".lua") == 1 then
        log.info("Local config for '" .. r2 .. "' found ...")
        break
      end
      f_h, f_he = nil, nil
    end
    log.warn("Local config for '" .. r .. "' does not yet exist!")
    local choice
    if f_he == nil then
      choice = vim.fn.confirm("Do you want to create it?", "&Yes\n&No", 2)
    else
      choice = vim.fn.confirm(
        "Do you want to create it?",
        "&Yes\n&No\n&Open Found",
        3
      )
    end
    if choice == 1 then
      local dirname = vim.fs.dirname(file_escaped)
      vim.fn.mkdir(dirname, "p")
      vim.fn.execute("keepjumps tabe " .. file_escaped)
      vim.api.nvim_buf_set_option(vim.fn.bufnr(), "bufhidden", "wipe")
    elseif choice == 3 then
      local dirname = vim.fs.dirname(f_he .. ".lua")
      vim.fn.mkdir(dirname, "p")
      vim.fn.execute("keepjumps tabe " .. f_he .. ".lua")
      vim.api.nvim_buf_set_option(vim.fn.bufnr(), "bufhidden", "wipe")
    end
    return
  end
  vim.fn.execute("keepjumps tabe " .. file_escaped)
  vim.api.nvim_buf_set_option(vim.fn.bufnr(), "bufhidden", "wipe")
end

---Removes local config for the currently oppened project.
---If it does not exist, it sends a warning.
---This prompts for confirmation before removing the file.
remove_local_config = function()
  local file_escaped, file, r = get_path(0)
  file = file .. ".lua"
  file_escaped = file_escaped .. ".lua"
  if vim.fn.filereadable(file) ~= 1 then
    local txt = "Local config for '" .. r .. "' does not exist!"
    log.warn(txt)
    return
  end
  local txt = "Are you sure you want to delete local config for: '"
    .. r
    .. "'"
  txt = txt .. "?"
  local choice = vim.fn.confirm(txt, "&Yes\n&No", 2)
  if choice == 2 then
    return
  end
  if vim.fn.delete(file) ~= -1 then
    txt = "Local config for '" .. r .. "' deleted"
    log.info(txt)
  else
    log.warn "Could not delete the local config!"
  end
end

local sourced = {}

---Check if there is a local config file matching the root
---of the currently oppened project.
---
---Do not source if the file has already been sourced.
---
---NOTE: if config not found for current root, check two levels
---up aswell.
local function source_local_config()
  for i = 0, DEPTH - 1 do
    local file_escaped, file, r = get_path(i)
    file = file .. ".lua"
    file_escaped = file_escaped .. ".lua"

    if sourced[file] ~= nil then
      return
    end
    if vim.fn.filereadable(file) == 1 then
      vim.fn.execute("source " .. file_escaped, false)
      log.debug("Sourced local config for: " .. r)
      sourced[file] = true
      return
    end
  end
end

-------------------------------------------- NOTE: source local config on start

source_local_config()
