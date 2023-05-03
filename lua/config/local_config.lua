--=============================================================================
-------------------------------------------------------------------------------
--                                                                 LOCAL CONFIG
--=============================================================================
-- Store all local configs in a directory in data stdpath
--
-- :LocalConfig
-------------------------------------------------------------------------------

local util = require "config.util"
local local_configs_path = util.path(vim.fn.stdpath "data", "local_configs")

local function open_local_config(path)
  vim.fn.execute("keepjumps tabe " .. path)
  vim.api.nvim_buf_set_option(vim.fn.bufnr(), "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(vim.fn.bufnr(), "swapfile", false)
end

local function find_local_config(source)
  local path = vim.fn.getcwd()
  local found = false

  while path:len() > 1 do
    local file = path .. ".lua"
    local escaped = util.path(local_configs_path, util.escape_path(file))

    if vim.fn.filereadable(escaped) == 1 then
      found = true
      if source then
        -- NOTE: when source is true, source the first found local
        -- config, otherwise ask the user whether to open it or not.
        vim.api.nvim_exec("source " .. escaped, false)
        if vim.g.keep_sourcing_local_config then
          vim.g.keep_sourcing_local_config = nil
        else
          return
        end
      else
        local choice = vim.fn.confirm(
          "Do you want to open config for " .. path .. "?",
          "&Yes\n&No",
          2
        )
        if choice == 1 then
          open_local_config(escaped)
          return
        end
      end
    end
    path = vim.fs.dirname(path)
  end
  if not found and not source then
    util.logger("Find Local Config"):warn "No local config found!"
  end
end

local function create_local_config()
  local path = vim.fn.getcwd()
  local file = path .. ".lua"
  local escaped = util.path(local_configs_path, util.escape_path(file))

  if vim.fn.filereadable(escaped) == 1 then
    util
        .logger("Create Local Config")
        :warn("Local config already exists for:", path)
    return
  end
  local dir = vim.fs.dirname(escaped)
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
  open_local_config(escaped)
end

local function remove_local_config()
  local path = vim.fn.getcwd()

  while path:len() > 1 do
    local file = path .. ".lua"
    local escaped = util.path(local_configs_path, util.escape_path(file))

    if vim.fn.filereadable(escaped) == 1 then
      local choice = vim.fn.confirm(
        "Do you want to delete config for " .. path .. "?",
        "&Yes\n&No",
        2
      )
      if choice == 1 then
        local log = util.logger "Remove Local Config"
        if vim.fn.delete(escaped) ~= -1 then
          log:info("Local config deleted for:", path)
        else
          log:warn("Could not delete the local config for:", path)
        end
      end
      return
    end
    path = vim.fs.dirname(path)
  end
end

local functions = {
  find = { find_local_config, { false } },
  source = { find_local_config, { true } },
  create = { create_local_config, {} },
  remove = { remove_local_config, {} },
}

vim.api.nvim_create_user_command("LocalConfig", function(opts)
  if not functions[opts.args] then
    find_local_config(false)
    return
  end
  local func = functions[opts.args]
  func[1](unpack(func[2]))
end, {
  nargs = "?",
  complete = function()
    local args = {}
    for k, _ in pairs(functions) do
      table.insert(args, k)
    end
    return args
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    find_local_config(true)
  end,
})
