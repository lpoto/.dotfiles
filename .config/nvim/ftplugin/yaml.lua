--=============================================================================
--                                                                FTPLUGIN-YAML
--=============================================================================
if vim.g[vim.bo.filetype] then return end

vim.g[vim.bo.filetype] = function()
  return {
    formatter = 'prettier',
    language_server = {
      name = 'yamlls',
      settings = {
        yaml = {
          keyOrdering = false,
        },
      },
    }
  }
end
