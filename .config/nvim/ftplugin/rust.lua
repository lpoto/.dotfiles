--=============================================================================
--                                                                FTPLUGIN-RUST
--=============================================================================
if vim.g[vim.bo.filetype] then return end

vim.g[vim.bo.filetype] = function()
  return {
    language_server = {
      name = "rust_analyzer",
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            features = "all",
          },
          checkOnSave = {
            command = "clippy",
          },
        },
      },
    },
  }
end
