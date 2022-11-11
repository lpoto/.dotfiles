--=============================================================================
-------------------------------------------------------------------------------
--                                                             ADD LOCAL CONFIG
--=============================================================================
-- Search if there is an existing local .nvim/ directory relative to the
-- current project, if there is, source it.
--_____________________________________________________________________________

DEFAULT = "default"
INIT = "init"
PLUGIN = "plugin"
FTPLUGIN = "ftplugin"
AFTER = "after"

local config_path = {} -- init, plugin, ftplugin, after
local loaded_scripts = {}

local source
local find_config

--NOTE: first find the config, then try to source
--it if any was found
--NOTE: this looks for configs in .nvim directories.
find_config()
source()

-- Start the search at the current working directory,
-- then search down the path, until `.nvim` directory is found.
find_config = function(depth)
  if depth == nil then
    depth = 10
  end
  config_path = {}
  local path = vim.fn.getcwd()

  while depth >= 0 do
    if path == nil then
      break
    end
    local default_ok = false
    local ok, e = vim.fs.dir(path .. "/.nvim")
    if ok ~= false and e ~= nil then
      for _, k in ipairs { PLUGIN, AFTER, FTPLUGIN } do
        local ok2, e2 = vim.fs.dir(path .. "/.nvim/" .. k)
        if ok2 ~= false and e2 ~= nil then
          default_ok = true
          config_path[k] = path .. "/.nvim/" .. k
        end
      end
      if vim.fn.filereadable(path .. "/.nvim/init.lua") then
        default_ok = true
        config_path[INIT] = path .. "/.nvim/init.lua"
      elseif vim.fn.filereadable(path .. "/.nvim/init.vim") then
        default_ok = true
        config_path[INIT] = path .. "/.nvim/init.vim"
      end
      if default_ok == true then
        config_path[DEFAULT] = path .. "/.nvim"
      end
      break
    end
    if path == "." then
      break
    end
    path = vim.fs.dirname(path)
    depth = depth - 1
  end
end

-- sources all the files in the directory provided with the 'path'
-- parameter. If ftplugin is true, instead of sourcing, a one-time
-- autocmds are created for the filetypes matching the names of
-- the files in the path. When those autocmds are triggered, the files
-- are sourced (1 file for each autocmd).
local function source_dir(path, ftplugin)
  if path == nil then
    return
  end
  local ok, e = vim.fs.dir(path)
  if ok == false or e == nil then
    return
  end
  if ftplugin == true then
    vim.api.nvim_create_augroup("LocalConfigAutogroup", { clear = true })
  end
  for name, t in vim.fs.dir(path) do
    if t == "file" and loaded_scripts[path .. "/" .. name] == nil then
      if ftplugin == true then
        local ft = name:gsub("%.lua", ""):gsub("%.vim", "")
        vim.api.nvim_create_autocmd("FileType", {
          pattern = ft,
          group = "LocalConfigAutogroup",
          once = true,
          command = "source " .. path .. "/" .. name,
        })
      else
        vim.cmd("source " .. path .. "/" .. name)
      end
      loaded_scripts[path .. "/" .. name] = true
    end
  end
end

-- Source .nvim directory found with find_config().
-- NOTE: first source .nvim/init.lua OR .nvim/init.vim,
-- then files in .nvim/plugin/, then creates autocmds for files in .nvim/ftplugin/
-- (when a file with filetype matching the filename in .nvim/ftplugin/ is oppened for the first time,
-- the file is sourced.), then source files in .nvim/after.
-- NOTE: find_config() should be called before using this function.
source = function()
  if config_path ~= nil and config_path[DEFAULT] then
    vim.notify(
      "Sourcing `" .. config_path[DEFAULT] .. "`",
      vim.log.levels.DEBUG
    )
    print("Sourcing `" .. config_path[DEFAULT] .. "`")
    if config_path[INIT] ~= nil then
      vim.api.nvim_exec("source " .. config_path[INIT])
    end
    source_dir(config_path[PLUGIN])
    source_dir(config_path[FTPLUGIN], true)
    source_dir(config_path[AFTER])
  end
end
