return {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.tbl_extend("force", vim.split(package.path, ";"), {
          "lua/?.lua",
          "lua/?/init.lua",
        }),
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
