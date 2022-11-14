--=============================================================================
-------------------------------------------------------------------------------
--                                                                 LOCAL CONFIG
--=============================================================================
-- Store local project configs in .local/ directory.
-- Configs are saved based on the root of the currently oppened project and
-- the current machine's hostname. Local configs specific to filetypes
-- may also be added.
-- Open/ add local configs with :LocalConfig <filetype>  (filetype is optional)
-- Remove them with :RemoveLocalConfig <filetype>  (filetype is optional)
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
---If a filetype is provided, it creates a project local config for
---the filetype.
---@param filetype string?
local function open_local_config(filetype)
  local file, file_escaped = path, path_escaped
  if filetype ~= nil and string.len(filetype) > 0 then
    file = file .. "." .. filetype
    file_escaped = file_escaped .. "." .. filetype
  end
  file = file .. ".lua"
  file_escaped = file_escaped .. ".lua"
  if vim.fn.filereadable(file) ~= 1 then
    if filetype ~= nil and string.len(filetype) > 0 then
      log.warn(
        "Local config for '"
          .. root
          .. "' ("
          .. filetype
          .. ") does not yet exist!"
      )
    else
      log.warn("Local config for '" .. root .. "' does not yet exist!")
    end
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
---If a filetype is provided, it removes a project local config for
---the filetype.
---This prompts for confirmation before removing the file.
---@param filetype string?
local function remove_local_config(filetype)
  local file, file_escaped = path, path_escaped
  if filetype ~= nil and string.len(filetype) > 0 then
    file = file .. "." .. filetype
    file_escaped = file_escaped .. "." .. filetype
  end
  file = file .. ".lua"
  file_escaped = file_escaped .. ".lua"
  if vim.fn.filereadable(file) ~= 1 then
    local txt = "Local config for '" .. root .. "'"
    if filetype ~= nil and string.len(filetype) > 0 then
      txt = txt .. " (" .. filetype .. ")"
    end
    txt = txt .. " does not exist!"
    log.warn(txt)
    return
  end
  local txt = "Are you sure you want to delete local config for: '"
    .. root
    .. "'"
  if filetype ~= nil and string.len(filetype) > 0 then
    txt = txt .. " (" .. filetype .. ")"
  end
  txt = txt .. "?"
  local choice = vim.fn.confirm(txt, "&Yes\n&No", 2)
  if choice == 2 then
    return
  end
  if vim.fn.delete(file) ~= -1 then
    txt = "Local config for '" .. root .. "'"
    if filetype ~= nil and string.len(filetype) > 0 then
      txt = txt .. " (" .. filetype .. ")"
    end
    txt = txt .. " deleted."
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
local function source_local_configs()
  local file, file_escaped = path, path_escaped
  local file_ft = file .. "." .. vim.o.filetype .. ".lua"
  local file_escaped_ft = file_escaped .. "." .. vim.o.filetype .. ".lua"
  file = file .. ".lua"
  file_escaped = file_escaped .. ".lua"
  if sourced[file] == nil then
    if vim.fn.filereadable(file) == 1 then
      vim.fn.execute("source " .. file_escaped, false)
      log.debug("Sourced local config for: " .. root)
    end
    sourced[file] = true
  end
  if sourced[file_ft] == nil then
    if vim.fn.filereadable(file_ft) == 1 then
      vim.fn.execute("source " .. file_escaped_ft, false)
      log.debug(
        "Sourced local config for: " .. root .. " (" .. vim.o.filetype .. ")"
      )
      sourced[file_ft] = true
    end
  end
end

---NOTE: use :LocalConfig  <ft>  command to open or create new
---project local config files, that will be saved in the .local directory.
vim.api.nvim_create_user_command("LocalConfig", function(o)
  if o.fargs ~= nil and next(o.fargs) ~= nil then
    open_local_config(o.fargs[1])
  else
    open_local_config()
  end
end, {
  nargs = "*",
})
---NOTE: use :RemoveLocalConfig  <ft>  command to remove existing
---project local config files, be saved in the .local directory.
vim.api.nvim_create_user_command("RemoveLocalConfig", function(o)
  if o.fargs ~= nil and next(o.fargs) ~= nil then
    remove_local_config(o.fargs[1])
  else
    remove_local_config()
  end
end, {
  nargs = "*",
})

--NOTE: when oppening a new filetype, try to source the
--default local config file and the local config file for the oppened
--filetype, if they have not yet been sourced.
vim.api.nvim_create_augroup("LocalConfig", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "LocalConfig",
  callback = source_local_configs,
})

--NOTE: source the local configs when entering neovim
vim.api.nvim_exec_autocmds("FileType", {
  group = "LocalConfig",
})
