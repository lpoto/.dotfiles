--=============================================================================
--                                   https://github.com/mfussenegger/nvim-jdtls
--=============================================================================

local M = {
  "mfussenegger/nvim-jdtls",
}

local util = {}

function M.init() util.set_up_autocommands() end

function util.set_up_autocommands()
  vim.api.nvim_create_autocmd("Filetype", {
    group = vim.api.nvim_create_augroup("jdtls.Ft", { clear = true }),
    callback = util.filetype_autocommand,
  })
end

function util.filetype_autocommand()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo.filetype
  local loaded = filetype .. "_jdtls_loaded"
  if vim.g[loaded] then return end

  vim.defer_fn(function()
    if vim.api.nvim_get_current_buf() ~= buf or vim.g[loaded] then return end
    vim.g[loaded] = true

    local opts = vim.g[filetype]
    if type(opts) == "function" then
      local ok, v = pcall(opts)
      if not ok then
        return vim.api.nvim_err_writeln(
          "Error in filetype config function: " .. v
        )
      end
      opts = v
      vim.g[filetype] = opts
    end
    util.attach(buf, opts)
  end, 200)
end

function util.attach(bufnr, opts)
  if type(opts) ~= "table" then return end
  local server = opts.server or opts.language_server
  if type(server) == "string" then server = { name = server } end
  local g_opts = vim.g.jdtls_config
    or vim.g.java_language_server
    or vim.g.java_server
  if type(g_opts) == "string" then
    opts = { name = g_opts }
  elseif type(g_opts) == "table" then
    if type(server) == "table" then
      server = vim.tbl_extend("force", server, g_opts)
    else
      server = g_opts
    end
  end
  if type(server) ~= "table" then return end
  if
    server.name ~= "jdtls"
    or type(vim.g.attached) == "table"
      and vim.tbl_contains(vim.g.attached, server.name)
  then
    return
  end

  if server.cmd == nil then
    local exe = vim.fn.exepath "jdtls"
    if not exe or exe:len() == 0 then
      return util.add_to_not_attached(server.name)
    end
  end

  server = util.get_jdtls_config(bufnr, server)

  local group = vim.api.nvim_create_augroup("StartJdtls", { clear = true })
  vim.api.nvim_create_autocmd("Filetype", {
    group = group,
    pattern = "java",
    callback = function() require("jdtls").start_or_attach(server) end,
  })
  vim.api.nvim_exec_autocmds("Filetype", { group = group })

  util.add_to_attached(server.name)
end

function util.get_jdtls_config(bufnr, opts)
  if type(opts) ~= "table" then opts = {} end
  if type(opts.root_dir) ~= "string" then
    opts.root_dir = util.find_root(bufnr)
  end
  if opts.autostart == nil then opts.autostart = true end
  if opts.cmd == nil then
    opts.cmd = {
      vim.fn.exepath "jdtls",
      "-Dlog.level=ERROR",
      "-config",
      (vim.fn.stdpath "cache") .. "/jdtls",
      "-data",
      (vim.fn.stdpath "cache") .. "/jdtls/workspace/" .. opts.root_dir,
    }
  end
  if type(vim.g.jdtls_config) == "table" then
    opts = vim.tbl_deep_extend("force", opts, vim.g.jdtls_config)
  end
  return opts
end

function util.find_root(buf)
  if
    type(vim.g.jdtls_root) == "string"
    and vim.fn.isdirectory(vim.g.jdtls_root) == 1
  then
    return vim.g.jdtls_root
  end
  if type(buf) ~= "number" or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_get_current_buf()
  end
  local pattern_kinds = {
    {
      "pom.xml",
    },
    {
      "settings.gradle",
      "settings.gradle.kts",
      "gradlew",
      "build.gradle",
      "build.gradle.kts",
      "build.xml",
    },
    {
      ".git",
    },
  }
  ---@diagnostic disable-next-line
  local home_dir = vim.uv.os_homedir()
  local file = vim.api.nvim_buf_get_name(buf)

  for _, patterns in ipairs(pattern_kinds) do
    local ok, dir = pcall(vim.fs.dirname, file)
    local found_dir = nil

    while
      ok
      and type(dir) == "string"
      and vim.fn.isdirectory(dir) == 1
      and dir:len() > home_dir:len()
      and dir ~= found_dir
    do
      local found = false
      for _, pattern in ipairs(patterns) do
        local p = dir .. "/" .. pattern
        if vim.fn.isdirectory(p) == 1 or vim.fn.filereadable(p) == 1 then
          found_dir, found = dir, true
          break
        end
      end
      if found_dir and not found then break end
      ok, dir = pcall(vim.fs.dirname, dir)
    end
    if found_dir then return found_dir end
  end
  return vim.fn.getcwd()
end

function util.add_to_attached(name)
  local attached = vim.g.attached
  if type(attached) ~= "table" then attached = {} end
  table.insert(attached, name)
  vim.g.attached = attached
end

function util.add_to_not_attached(name)
  local not_attached = vim.g.not_attached
  if type(not_attached) ~= "table" then not_attached = {} end
  table.insert(not_attached, name)
  vim.g.not_attached = not_attached
end

return M
