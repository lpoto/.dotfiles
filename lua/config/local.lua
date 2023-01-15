local Path = require "plenary.path"
local version = require "util.version"

local config = nil
local loaded = {}

local parse_config
local parse_filetype
local secure_read_config
local load_local_config

local M = {}

M.filename = ".nvim.lua"
M.config_path = { vim.fn.stdpath "config", M.filename }
M.augroup = "LocalConfigAugroup"
M.title = "Local Config"

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
  vim.api.nvim_create_autocmd("Filetype", {
    group = M.augroup,
    callback = parse_config,
  })
  vim.api.nvim_create_autocmd("DirChanged", {
    group = M.augroup,
    callback = load_local_config,
  })

  config = secure_read_config(Path:new(M.config_path))

  load_local_config()
  parse_config()
end

load_local_config = function()
  local ok, e = pcall(function()
    local cwd = vim.loop.cwd()
    local parents = Path:new(cwd) or {}
    table.insert(parents, cwd)
    for _, parent in ipairs(parents) do
      if parent == vim.fn.stdpath "config" then
        return
      end
      local path = Path:new(parent, M.filename)
      if path:is_file() then
        local c = secure_read_config(path)
        if next(c or {}) ~= nil then
          config =
            vim.tbl_extend("force", config or {}, secure_read_config(path))
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

parse_config = function(force)
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
  local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
  if buftype:len() ~= 0 then
    return
  end
  local opts = {}
  if type(config) == "table" then
    opts = config
  end
  for k, v in pairs(opts) do
    if k == filetype then
      local ok, e = pcall(parse_filetype, filetype, v, force)
      if not ok and type(e) == "string" then
        vim.notify(e, vim.log.levels.WARN, {
          title = M.title,
        })
      end
    end
  end
end

parse_filetype = function(filetype, opts, force)
  if loaded[filetype] and not force then
    return
  end
  assert(type(opts) == "table", "Filetype config should be a table!")

  loaded[filetype] = true
  for k, v in pairs(opts) do
    if k == "formatter" then
      require("plugins.null-ls").register_builtin_source(
        "formatting",
        v,
        filetype
      )
    elseif k == "copilot" and v then
      require("plugins.copilot").enable(filetype)
    elseif k == "linter" then
      require("plugins.null-ls").register_builtin_source(
        "diagnostics",
        v,
        filetype
      )
    elseif k == "language_server" then
      require("plugins.lsp").add_language_server(v)
    end
  end
end

secure_read_config = function(path)
  if not path or not path:is_file() then
    return
  end

  local s = vim.secure.read(path:__tostring())
  local ok, v = pcall(loadstring, s)
  if not ok and type(v) == "stirng" then
    vim.notify(v, vim.log.levels.WARN, {
      title = M.title,
    })
    return {}
  end
  if type(v) ~= "function" then
    return {}
  end
  ok, v = pcall(v)
  if not ok and type(v) == "stirng" then
    vim.notify(v, vim.log.levels.WARN, {
      title = M.title,
    })
    return {}
  end
  return v or {}
end

return M
