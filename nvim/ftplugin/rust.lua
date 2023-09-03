--=============================================================================
-------------------------------------------------------------------------------
--                                                                       RUST
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

Lsp:attach("rustfmt")
Lsp:attach({
  name = "rust_analyzer",
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        allFeatures = true,
        overrideCommand = {
          "cargo",
          "clippy",
          "--workspace",
          "--message-format=json",
          "--all-targets",
          "--all-features",
        },
      },
    },
  },
})
