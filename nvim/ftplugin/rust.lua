--=============================================================================
-------------------------------------------------------------------------------
--                                                                       RUST
--[[===========================================================================
Loaded when a rust file is opened
-----------------------------------------------------------------------------]]
Util.ftplugin()
  :new()
  :attach_formatter("rustfmt")
  :attach_language_server("rust_analyzer", {
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
