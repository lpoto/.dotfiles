--=============================================================================
--                                                          PLUGIN-LOCAL-CONFIG
--=============================================================================
if vim.g.did_local or vim.api.nvim_set_var("did_local", true) then return end

local M = {
  local_dir = vim.fn.stdpath "data" .. "/local",
}

function M.init()
  if M.__initialized then return M end
  M.__initialized = true
  M.set_up_autocommands()
  M.set_up_user_commands()
  return M
end

function M.set_up_autocommands()
  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    group = vim.api.nvim_create_augroup("local_config", { clear = true }),
    callback = M.__source_config,
  })
end

function M.set_up_user_commands()
  vim.api.nvim_create_user_command("LocalConfig", M.__cmd, {
    complete = function() return { "source", "edit", "delete" } end,
    nargs = "*",
  })
end

function M.__cmd(opts)
  if type(opts) == "table" and type(opts.fargs) == "table" then
    if vim.tbl_contains(opts.fargs, "source") then
      return M.__source_config()
    end
    if vim.tbl_contains(opts.fargs, "delete") then
      return M.__delete_config()
    end
  end
  return M.__open_config()
end

function M.__source_config()
  vim.schedule(function()
    local cwd = vim.fn.getcwd()
    ---@diagnostic disable-next-line: undefined-field
    local home_dir = vim.uv.os_homedir()
    local logs = {}
    while cwd:len() >= home_dir:len() do
      local tail = M.__escape_file(cwd) .. ".lua"
      local file = M.local_dir .. "/" .. tail
      local content = vim.secure.read(file)
      if type(content) == "string" then
        local ok, err = pcall(loadstring, content)
        if not ok then
          vim.notify(
            "Error loading local config " .. file .. ": " .. err,
            vim.log.levels.ERROR
          )
          return
        end
        table.insert(logs, "Sourced local config for: " .. cwd)
      end
      local new_cwd = vim.fs.dirname(cwd)
      if not new_cwd or new_cwd:len() >= cwd:len() then break end
      cwd = new_cwd
    end
    for _, log in ipairs(logs) do
      vim.notify(log, vim.log.levels.DEBUG)
    end
  end)
end

function M.__delete_config()
  vim.schedule(function()
    local cwd = vim.fn.getcwd()
    local tail = M.__escape_file(cwd) .. ".lua"
    local file = M.local_dir .. "/" .. tail
    if vim.fn.filereadable(file) ~= 1 then
      vim.notify("No local config found for " .. cwd)
      return
    end
    local r =
      vim.fn.confirm("Delete local config for " .. cwd .. "?", "&Yes\n&No", 2)
    if r ~= 1 then return end
    vim.fn.delete(file)
    vim.notify("Deleted local config for " .. cwd)
  end)
end

function M.__open_config()
  vim.schedule(function()
    if vim.bo.modified then
      vim.notify "Cannot open local config: buffer is modified"
      return
    end
    local cwd = vim.fn.getcwd()
    local tail = M.__escape_file(cwd) .. ".lua"
    local file = M.local_dir .. "/" .. tail
    local parent = vim.fs.dirname(file)
    if not parent then return end
    if vim.fn.isdirectory(parent) ~= 1 then vim.fn.mkdir(parent, "p") end

    vim.cmd("silent! keepjumps tabe " .. vim.fn.fnameescape(file))
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
    vim.api.nvim_set_option_value("buflisted", false, { buf = buf })
    vim.api.nvim_set_option_value("buftype", "", { buf = buf })
    vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
    if vim.api.nvim_buf_line_count(buf) <= 1 then
      vim.api.nvim_buf_set_lines(
        buf,
        0,
        -1,
        false,
        { "-- Local config for: " .. cwd }
      )
    end
    vim.api.nvim_set_option_value("modified", false, { buf = buf })
  end)
end

function M.__escape_file(file) return file:gsub("/", "_") .. "_" end

function M.__unescape_file(file) return file:gsub("_", "/"):gsub("/$", "") end

return M.init()
