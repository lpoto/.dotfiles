--=============================================================================
-------------------------------------------------------------------------------
--                                                                         ROOT
--=============================================================================
-- Config for finding a project's root directory
--_____________________________________________________________________________

local function get_root(root_dir_patterns)
  if type(root_dir_patterns) ~= "table" then
    if vim.fn.exists "g:root_dir_patterns" == 1 then
      root_dir_patterns = vim.g["root_dir_patterns"]
    else
      root_dir_patterns = {
        ".git",
        ".nvim",
        "package.json",
        "mvnw",
        ".opam",
        "GemFile",
        ".nvim.root",
      }
    end
  end
  local max_depth = 30
  if vim.g["root_dir_max_depth"] then
    max_depth = vim.g["root_dir_max_depth"]
  end
  local default_path_maker = "%:p:h"
  local path_maker = default_path_maker
  for _ = 1, max_depth, 1 do
    local path = vim.fn.expand(path_maker)
    for _, pattern in ipairs(root_dir_patterns) do
      if
        vim.fn.filereadable(path .. "/" .. pattern) == 1
        or vim.fn.isdirectory(path .. "/" .. pattern) == 1
      then
        return path
      end
    end
    if string.len(path) == 1 then
      break
    end
    path_maker = path_maker .. ":h"
  end
  return vim.fn.expand(default_path_maker)
end

return get_root
