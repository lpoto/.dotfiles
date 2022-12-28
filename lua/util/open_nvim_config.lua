--=============================================================================
-------------------------------------------------------------------------------
--                                                             OPEN NVIM CONFIG
--=============================================================================
-- Open the neovim init.lua file and set cwd to config stdpath
--_____________________________________________________________________________

local ok, e = pcall(
  vim.api.nvim_exec,
  "find " .. vim.fn.stdpath "config" .. "/init.lua",
  false
)
if ok == false then
  vim.notify(e, vim.log.levels.ERROR)
else
  vim.fn.chdir(vim.fn.stdpath "config")
end
