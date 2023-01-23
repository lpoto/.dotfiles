--=============================================================================
-------------------------------------------------------------------------------
--                                                                  JSON_CONFIG
--=============================================================================
-- Safely source local .nvim.json files, those files should contain
-- filetype keys or a plugin key.
--_____________________________________________________________________________

local Path = require "plenary.path"
local version = require "version"

local config = nil
local loaded = {}

local parse_config
local parse_filetype
local parse_plugins
local parse_tasks
local secure_read_config
local load_local_config

local M = {}

M.filename = ".nvim.json"
M.config_path = { vim.fn.stdpath "config", M.filename }
M.augroup = "JsonConfigAugroup"
M.title = "Json Config"

function M.config()
  if not version.check() then
    vim.notify(
      "Sourcing '.nvim.lua' files is disabled, as the neovim version is too low",
      vim.log.levels.WARN,
      {
        title = M.title,
      }
    )
    return
  end

  vim.api.nvim_create_augroup(M.augroup, {
    clear = true,
  })
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = M.augroup,
    callback = function()
      vim.schedule(parse_config)
    end,
  })
  vim.api.nvim_create_autocmd("DirChanged", {
    group = M.augroup,
    callback = function()
      vim.schedule(function()
        load_local_config()
        parse_config(true)
      end)
    end,
  })

  vim.schedule(function()
    config = secure_read_config(Path:new(M.config_path))

    load_local_config()

    parse_config(false, true)
  end)
end

load_local_config = function()
  local ok, e = pcall(function()
    local cwd = vim.loop.cwd()
    local parents = Path:new(cwd):parents() or {}
    table.insert(parents, cwd)
    for _, parent in ipairs(parents) do
      if parent == vim.fn.stdpath "config" then
        return
      end
    end
    for _, parent in ipairs(parents) do
      local path = Path:new(parent, M.filename)
      if path:is_file() then
        local c = secure_read_config(path)
        if next(c or {}) then
          config = config or {}
          config = vim.tbl_deep_extend("force", config, c or {})
          vim.notify("Loaded local config: " .. path:__tostring())
        end
        return
      end
    end
  end)
  if not ok and type(e) == "string" then
    vim.notify(e, vim.log.levels.ERROR, {
      title = M.title,
    })
  end
end

parse_config = function(force, init)
  if type(config) ~= "table" or next(config) == nil then
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
  local buftype = vim.api.nvim_buf_get_option(buf, "buftype")

  local opts = config

  if not init and buftype:len() ~= 0 then
    return
  end

  if opts.plugins and (not loaded.plugins or force) then
    loaded.plugins = true
    local ok, e = pcall(parse_plugins, opts.plugins)
    if not ok and type(e) == "string" then
      vim.notify(e, vim.log.levels.WARN, {
        title = M.title,
      })
    end
  end

  if opts.tasks and (not loaded.tasks or force) then
    loaded.tasks = true
    local ok, e = pcall(parse_tasks, opts.tasks)
    if not ok and type(e) == "string" then
      vim.notify(e, vim.log.levels.WARN, {
        title = M.title,
      })
    end
  end

  if opts[filetype] and (not loaded[filetype] or force) then
    loaded[filetype] = true
    local ok, e = pcall(parse_filetype, filetype, opts[filetype], force)
    if not ok and type(e) == "string" then
      vim.notify(e, vim.log.levels.WARN, {
        title = M.title,
      })
    end
  end
end

parse_plugins = function(plugins)
  assert(type(plugins) == "table", "Plugins config should be a table")

  for k, v in pairs(plugins) do
    assert(type(k) == "string", "Plugin name should be a string")
    local ok, m = pcall(require, "plugins." .. k)
    assert(ok, m)
    assert(type(v) == "table", "Plugin configs should be tables")
    for k2, v2 in pairs(v) do
      assert(type(k2) == "string", "Plugin config keys should be strings")
      m[k2] = v2
    end
  end
end

parse_tasks = function(tasks)
  assert(type(tasks) == "table", "Tasks config should be a table")
  for _, v in pairs(tasks) do
    assert(type(v) == "table", "Tasks generator should be a table!")
    assert(
      type(v.generator) == "table" or type(v.generator) == "function",
      "Task's generator should have a table or a function generator field!"
    )
    if type(v.generator) == "table" then
      local generator = v.generator
      v.generator = function()
        return generator
      end
    end
    if not v.opts then
      v.opts = v.options or {}
    end
  end
  require("telescope").extensions.tasks.generators.custom.add(unpack(tasks))
end

parse_filetype = function(filetype, opts)
  assert(type(opts) == "table", "Filetype config should be a table!")
  for k, v in pairs(opts) do
    if v ~= false then
      if k == "formatter" then
        assert(
          v == false or type(v) == "string",
          "formatter should be a string!"
        )
        if type(v) == "string" then
          require("plugins.null-ls").register_builtin_source(
            "formatting",
            v,
            filetype
          )
        end
      elseif k == "linter" then
        assert(
          v == false or type(v) == "string",
          "linter should be a string!"
        )
        if type(v) == "string" then
          require("plugins.null-ls").register_builtin_source(
            "diagnostics",
            v,
            filetype
          )
        end
      elseif k == "language_server" then
        assert(
          v == false or type(v) == "string",
          "language_server should be a string!"
        )
        local c = opts["language_server_config"]
        assert(
          c == nil or type(c) == "table" or c == false,
          "language_server_config should be a table!"
        )
        if c == false then
          c = nil
        end
        if v ~= false then
          require("plugins.lspconfig").add_language_server(v, c)
        end
      end
    end
  end
end

secure_read_config = function(path)
  if not path or not path:is_file() then
    return
  end

  local s = vim.secure.read(path:__tostring())
  if s == nil or s:len() == 0 then
    return {}
  end
  local ok, v = pcall(vim.json.decode, s)
  if not ok and type(v) == "string" then
    vim.notify(v, vim.log.levels.WARN, {
      title = M.title,
    })
    return {}
  end
  if type(v) ~= "table" then
    return {}
  end
  local handle
  handle = function(o)
    if type(o) == "string" then
      if string.match(o, "^lua ") then
        local ok2, v2 = pcall(loadstring, string.sub(o, 4))
        if not ok2 and type(v2) == "string" then
          vim.notify(v2, vim.log.levels.WARN, {
            title = M.title,
          })
          return o
        end
        if type(v2) ~= "function" then
          return o
        end
        ok2, o = pcall(v2)
        if not ok2 and type(v2) == "string" then
          vim.notify(v2, vim.log.levels.WARN, {
            title = M.title,
          })
          return o
        end
        return o
      end
    end
    if type(o) ~= "table" then
      return o
    end
    for k2, v2 in pairs(o) do
      o[k2] = handle(v2)
    end
    return o
  end
  return handle(v)
end

return M
