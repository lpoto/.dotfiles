--=============================================================================
-------------------------------------------------------------------------------
--                                                                 LOCAL CONFIG
--=============================================================================
-- Enable neovim's exrc option so it shources local
--    .nvim.init
--    .nvimrc
--    .exrc
-- Files.
--
-- This required version 0.9 so the local files are sourced safely.
--_____________________________________________________________________________

local version = require "util.version"
local loaded_configs = {}

local M = {}

---Load local .nvim.init, .nvimrc or .exrc files (the first found).
---Start in current directory and check 2 directories up.
---Version 0.9 is required for this to work safely.
function M.enable()
  vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
      M.secure_read_local_config()
    end,
  })
  vim.api.nvim_exec_autocmds("DirChanged", {})
end

function M.secure_read_local_config()
  local cwd = vim.fn.getcwd()
  for _ = 1, 3 do
    for _, name in ipairs { ".nvim.lua", ".nvimrc", ".exrc" } do
      if vim.fn.file_readable(cwd .. "/" .. name) == 1 then
        if loaded_configs[cwd .. "/" .. name] then
          return
        end
        loaded_configs[cwd .. "/" .. name] = true
        if not version.check() then
          vim.notify(
            "Version "
              .. version.required_version
              .. " or higher is required to use local config files.",
            vim.log.levels.WARN,
            { title = "Local Config" }
          )
          return
        end
        local s = vim.secure.read(cwd .. "/" .. name)
        if s ~= nil then
          local loaded = true
          if string.len(s) > 0 then
            local ok, e = pcall(vim.fn.luaeval, s)
            if ok == false then
              vim.notify(e, vim.log.levels.ERROR, { title = "Local Config" })
              loaded = false
            end
          end
          if loaded then
            vim.notify(
              "Loaded " .. cwd .. "/" .. name,
              vim.log.levels.INFO,
              { title = "Local Config" }
            )
          end
        end
        return
      end
    end
    local cwd2 = vim.fs.dirname(cwd)
    if cwd == cwd2 then
      return
    end
    cwd = cwd2
  end
end

return M
