--=============================================================================
-------------------------------------------------------------------------------
--                                                                 LOCAL CONFIG
--=============================================================================
-- Store all local configs in a directory in data stdpath
-------------------------------------------------------------------------------

local local_configs_path = vim.fn.stdpath "data" .. "/local_configs"

local function escape_path(path)
  return vim.fn.substitute(path, "/", "_", "g")
end

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
    local escaped = local_configs_path .. "/" .. escape_path(file)

    if vim.fn.filereadable(escaped) == 1 then
      found = true
      if source then
        -- NOTE: when source is true, source the first found local
        -- config, otherwise ask the user whether to open it or not.
        vim.api.nvim_exec("source " .. escaped, false)
        return
      end
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
    path = vim.fs.dirname(path)
  end
  if not found and not source then
    vim.notify("No local config found!", vim.log.levels.WARN, {
      title = "Local Config",
    })
  end
end

local function create_local_config()
  local path = vim.fn.getcwd()
  local file = path .. ".lua"
  local escaped = local_configs_path .. "/" .. escape_path(file)

  if vim.fn.filereadable(escaped) == 1 then
    vim.notify(
      "Local config for '" .. path .. "' already exists!",
      vim.log.levels.WARN,
      {
        title = "Local Config",
      }
    )
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
    local escaped = local_configs_path .. "/" .. escape_path(file)

    if vim.fn.filereadable(escaped) == 1 then
      local choice = vim.fn.confirm(
        "Do you want to delete config for " .. path .. "?",
        "&Yes\n&No",
        2
      )
      if choice == 1 then
        if vim.fn.delete(escaped) ~= -1 then
          local txt = "Local config for '" .. path .. "' deleted"
          vim.notify(txt, vim.log.levels.INFO, {
            title = "Local Config",
          })
        else
          vim.notify("Could not delete the local config!", vim.log.levels.WARN, {
            title = "Local Config",
          })
        end
      end
      return
    end
    path = vim.fs.dirname(path)
  end
end

vim.api.nvim_create_user_command("LocalConfig", function()
  find_local_config(false)
end, {})

vim.api.nvim_create_user_command("CreateLocalConfig", function()
  create_local_config()
end, {})

vim.api.nvim_create_user_command("RemoveLocalConfig", function()
  remove_local_config()
end, {})

vim.api.nvim_create_user_command("SourceLocalConfig", function()
  find_local_config(true)
end, {})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    find_local_config(true)
  end,
})
