--=============================================================================
-------------------------------------------------------------------------------
--                                                                   NVIM-JDTLS
--[[===========================================================================
https://github.com/mfussenegger/nvim-jdtls
-----------------------------------------------------------------------------]]

local M = {
  "mfussenegger/nvim-jdtls",
}

local find_root
vim.lsp.add_attach_condition({
  priority = 100,
  fn = function(opts, bufnr)
    if type(opts) ~= "table" or opts.name ~= "jdtls" then return end

    if type(opts.root_dir) ~= "string" then
      opts.root_dir = find_root(bufnr)
    end
    if opts.cmd == nil then
      local exe = vim.fn.exepath("jdtls")
      if not exe or exe:len() == 0 then
        return { non_executable = { "jdtls" } }
      end
      opts.cmd = {
        exe,
        "-data",
        vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. opts.root_dir,
      }
    end

    local client_id = require("jdtls").start_or_attach(opts)
    local attach_jdtls_to_buf = function(buf)
      if
        type(buf) ~= "number"
        or not vim.api.nvim_buf_is_valid(buf)
        or vim.api.nvim_buf_get_option(buf, "buftype") ~= ""
        or vim.api.nvim_buf_get_option(buf, "filetype") ~= "java"
      then
        return
      end
      local client = vim.lsp.get_client_by_id(client_id)
      if client then vim.lsp.buf_attach_client(buf, client_id) end
    end

    vim.api.nvim_create_autocmd("Filetype", {
      pattern = "java",
      callback = function(o) attach_jdtls_to_buf(o.buf) end,
    })
    for _, v in ipairs(vim.api.nvim_list_bufs()) do
      attach_jdtls_to_buf(v)
    end

    return { attached = { opts.name } }
  end,
})

function find_root(buf)
  if type(buf) ~= "number" or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_get_current_buf()
  end
  local patterns = {
    "mvn",
    "pom.xml",
    "settings.gradle",
    "settings.gradle.kts",
    "gradlew",
    "build.gradle",
    "build.gradle.kts",
    "build.xml",
  }
  local path = vim.api.nvim_buf_get_name(buf)
  local cwd = vim.fn.getcwd()
  local parents = {}
  local n = nil
  for parent in vim.fs.parents(path) do
    if type(n) == "number" then
      if n == 0 then break end
      n = n - 1
    end
    if parent:len() <= 2 or parent == vim.loop.os_homedir() then break end
    table.insert(parents, 1, parent)
    if parent:len() <= cwd:len() then n = 2 end
  end
  for _ = 1, 2 do
    for _, parent in ipairs(parents) do
      for _, pattern in ipairs(patterns) do
        local p = parent .. "/" .. pattern
        if vim.fn.filereadable(p) == 1 then return parent end
      end
    end
    table.insert(patterns, ".git")
  end
  return cwd
end

return M
