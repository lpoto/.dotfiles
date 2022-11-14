--=============================================================================
-------------------------------------------------------------------------------
--                                                             ADD LOCAL CONFIG
--=============================================================================
-- Search if there is an existing local .nvim/ directory relative to the
-- current project, if there is, source it.
--_____________________________________________________________________________

---Gets the base of the path for the local config based on the root
---of the currently oppened project.
---The returned path is missing .<filetype>.lua or just .lua at the end.
---
---@return string: base of the path
---@return string: escaped base of the path
local function get_local_config_path_base()
  local local_configs_path = vim.fn.stdpath "config" .. "/.local"
  local root = require "util.root"()
  local base = local_configs_path .. "/" .. vim.fn.hostname() .. "/"
  local path_escaped = base
    .. vim.fn.substitute(
      vim.fn.substitute(root, "\\", "\\\\%", "g"),
      "/",
      "\\\\%",
      "g"
    )
  local path = base
    .. vim.fn.substitute(
      vim.fn.substitute(root, "\\", "\\%", "g"),
      "/",
      "\\%",
      "g"
    )
  return path, path_escaped
end

---Opens local config for the currently oppened project.
---If it does not exist, it prompts the option to create it.
---If a filetype is provided, it creates a project local config for
---the filetype.
local function open_local_config(filetype)
  local root = require "util.root"()
  local file, file_escaped = get_local_config_path_base()
  if filetype ~= nil and string.len(filetype) > 0 then
    file = file .. "." .. filetype
    file_escaped = file_escaped .. "." .. filetype
  end
  file = file .. ".lua"
  file_escaped = file_escaped .. ".lua"
  if vim.fn.filereadable(file) ~= 1 then
    if filetype ~= nil and string.len(filetype) > 0 then
      vim.notify(
        "Local config for '"
          .. root
          .. "' ("
          .. filetype
          .. ") does not yet exist!",
        vim.log.levels.WARN
      )
    else
      vim.notify(
        "Local config for '" .. root .. "' does not yet exist!",
        vim.log.levels.WARN
      )
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

---Opens local config for the currently oppened project.
---If it does not exist, it prompts the option to create it.
---If a filetype is provided, it creates a project local config for
---the filetype.
local function remove_local_config(filetype)
  local root = require "util.root"()
  local file, file_escaped = get_local_config_path_base()
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
    vim.notify(txt, vim.log.levels.WARN)
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
    vim.notify(txt, vim.log.levels.INFO)
  else
    vim.notify("Could not delete the local config!", vim.log.levels.WARN)
  end
end

local sourced = {}

local function source_local_configs()
  local file, file_escaped = get_local_config_path_base()
  local file_ft = file .. "." .. vim.o.filetype .. ".lua"
  local file_escaped_ft = file_escaped .. "." .. vim.o.filetype .. ".lua"
  file = file .. ".lua"
  file_escaped = file_escaped .. ".lua"
  if sourced[file] == nil then
    if vim.fn.filereadable(file) == 1 then
      vim.fn.execute("source " .. file_escaped, false)
      vim.notify("Sourced local config for: " .. require "util.root"())
    end
    sourced[file] = true
  end
  if sourced[file_ft] == nil then
    if vim.fn.filereadable(file_ft) == 1 then
      vim.fn.execute("source " .. file_escaped_ft, false)
      vim.notify(
        "Sourced local config for: "
          .. require "util.root"()
          .. " ("
          .. vim.o.filetype
          .. ")"
      )
      sourced[file_ft] = true
    end
  end
end

vim.api.nvim_create_user_command("LocalConfig", function(o)
  if o.fargs ~= nil and next(o.fargs) ~= nil then
    open_local_config(o.fargs[1])
  else
    open_local_config()
  end
end, {
  nargs = "*",
})
vim.api.nvim_create_user_command("RemoveLocalConfig", function(o)
  if o.fargs ~= nil and next(o.fargs) ~= nil then
    remove_local_config(o.fargs[1])
  else
    remove_local_config()
  end
end, {
  nargs = "*",
})

vim.api.nvim_create_augroup("LocalConfig", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "LocalConfig",
  callback = source_local_configs,
})

source_local_configs()
