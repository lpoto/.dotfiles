--=============================================================================
--                                                                FTPLUGIN-JAVA
--=============================================================================
if vim.g[vim.bo.filetype] then return end

local java_root
vim.g[vim.bo.filetype] = function()
  return {
    language_server = {
      name = "jdtls",
      root_dir = java_root,
    },
  }
end

function java_root()
  local pattern_kinds = { { "pom.xml" }, { "build.xml" }, { ".git" } }
  ---@diagnostic disable-next-line
  local home_dir = vim.uv.os_homedir()
  local file = vim.api.nvim_buf_get_name(0)
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
