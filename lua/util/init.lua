--=============================================================================
-------------------------------------------------------------------------------
--                                                                         UTIL
--=============================================================================
-- Utility lua functions
--_____________________________________________________________________________

local util = {}

---Find the root directory of the current project.
---Searches for the first directory in the path that contains one
---provided patterns.
---@param root_dir_patterns table?: (default: {'.git', '.nvim.root'})
---@param max_depth number?:  max depth to check for root (default: 10)
function util.get_root(root_dir_patterns, max_depth)
  if type(root_dir_patterns) ~= "table" or next(root_dir_patterns) == nil then
    root_dir_patterns = { ".git", ".nvim.root", ".nvim" }
  end
  if type(max_depth) ~= "number" then
    max_depth = 20
  end
  if vim.g["root_dir_max_depth"] then
    max_depth = vim.g["root_dir_max_depth"]
  end
  local default_path_maker = "%:p:h"
  local path_maker = default_path_maker
  for _ = 1, max_depth, 1 do
    local path = vim.fn.expand(path_maker)
    if string.len(path) == 1 or path .. "/" == vim.fn.expand "~/" then
      break
    end
    for _, pattern in ipairs(root_dir_patterns) do
      if
        vim.fn.filereadable(path .. "/" .. pattern) == 1
        or vim.fn.isdirectory(path .. "/" .. pattern) == 1
      then
        return path
      end
    end
    path_maker = path_maker .. ":h"
  end
  return vim.fn.expand(default_path_maker)
end

return util
