--=============================================================================
-------------------------------------------------------------------------------
--                                                                  COLORSCHEME
--=============================================================================
-- load colorschemes configured in lua/plugins/colorschemes/
--_____________________________________________________________________________

local colorschemes = {}

for _, file in
  ipairs(
    vim.fn.readdir(vim.fn.stdpath "config" .. "/lua/plugins/colorschemes/")
  )
do
  if file ~= "init.lua" then
    table.insert(
      colorschemes,
      require("plugins.colorschemes." .. file:gsub("%.lua$", ""))
    )
  end
end

return colorschemes
