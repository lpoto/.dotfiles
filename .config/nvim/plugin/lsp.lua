-- NOTE: Override default lsp enable, so that
-- we may call the enable from ftplugin files
local f = vim.lsp.enable
---@diagnostic disable-next-line
vim.lsp.enable = function(...)
  f(...)
  if vim.bo.filetype ~= "" and vim.bobuftype ~= "" then
    vim.api.nvim_exec_autocmds("FileType", {
      group = "nvim.lsp.enable",
    })
  end
end

-- NOTE: enable all lsp servers defined in lua/lsp
local function get_defined_language_servers()
  local lsp_dir = vim.fn.stdpath "config" .. "/lsp/"
  local files = {}
  ---@diagnostic disable-next-line
  local fs = vim.loop.fs_scandir(lsp_dir)
  if not fs then return {} end
  while true do
    ---@diagnostic disable-next-line
    local name, type = vim.loop.fs_scandir_next(fs)
    if not name then break end -- Stop when there are no more files
    local name_without_ext = name:match "(.+)%..+$" or name
    table.insert(files, name_without_ext)
  end
  return files
end

vim.lsp.enable(get_defined_language_servers())
