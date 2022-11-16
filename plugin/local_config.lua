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

---The root of the currently oppened project
---@type string
local root = require("util").get_root()
---The defult path for the local config files
---@type string
local local_configs_path = vim.fn.stdpath "config" .. "/.local"
---The base of the local config files for the current host
---@type string
local base = local_configs_path .. "/" .. vim.fn.hostname() .. "/"
---The escaped base of the current local project file
---@type string
local path_escaped = base
  .. vim.fn.substitute(
    vim.fn.substitute(root, "\\", "\\\\%", "g"),
    "/",
    "\\\\%",
    "g"
  )
---The uneescaped base of the current local project file
---@type string
local path = base
  .. vim.fn.substitute(
    vim.fn.substitute(root, "\\", "\\%", "g"),
    "/",
    "\\%",
    "g"
  )

---Opens local config for the currently oppened project.
---If it does not exist, it prompts the option to create it.
local function open_local_config()
  local file, file_escaped = path, path_escaped
  file = file .. ".lua"
  file_escaped = file_escaped .. ".lua"
  if vim.fn.filereadable(file) ~= 1 then
    log.warn("Local config for '" .. root .. "' does not yet exist!")
    local choice = vim.fn.confirm("Do you want to create it?", "&Yes\n&No", 2)
    if choice == 1 then
      local dirname = vim.fs.dirname(file_escaped)
      vim.fn.mkdir(dirname, "p")
      vim.fn.execute("keepjumps tabe " .. file_escaped)
      vim.api.nvim_buf_set_option(vim.fn.bufnr(), "bufhidden", "wipe")
    end
    return
  else
    vim.fn.execute("keepjumps tabe " .. file_escaped)
    vim.api.nvim_buf_set_option(vim.fn.bufnr(), "bufhidden", "wipe")
  end
end

---Removes local config for the currently oppened project.
---If it does not exist, it sends a warning.
---This prompts for confirmation before removing the file.
local function remove_local_config()
  local file, file_escaped = path, path_escaped
  file = file .. ".lua"
  file_escaped = file_escaped .. ".lua"
  if vim.fn.filereadable(file) ~= 1 then
    local txt = "Local config for '" .. root .. "' does not exist!"
    log.warn(txt)
    return
  end
  local txt = "Are you sure you want to delete local config for: '"
    .. root
    .. "'"
  txt = txt .. "?"
  local choice = vim.fn.confirm(txt, "&Yes\n&No", 2)
  if choice == 2 then
    return
  end
  if vim.fn.delete(file) ~= -1 then
    txt = "Local config for '" .. root .. "' deleted"
    log.info(txt)
  else
    log.warn "Could not delete the local config!"
  end
end

local sourced = {}

---Check if there is a local config file matching the root
---of the currently oppened project. Also source the file matching
---both the root and the current filetype.
---Do not source if the file has already been sourced.
---NOTE: if config not found for current root, check two levels
---up aswell.
local function source_local_configs()
  local file, file_escaped = path, path_escaped
  file = file .. ".lua"
  file_escaped = file_escaped .. ".lua"

  if sourced[file] == nil then
    if vim.fn.filereadable(file) == 1 then
      vim.fn.execute("source " .. file_escaped, false)
      log.debug("Sourced local config for: " .. root)
    end
  end
  sourced[file] = true
end

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
  source_local_configs()
end, {})

-- NOTE: source local configs on start
source_local_configs()
