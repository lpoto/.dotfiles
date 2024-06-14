--=============================================================================
--                                       https://github.com/nvim-java/nvim-java
--=============================================================================
local M = {
  "nvim-java/nvim-java",
  dependencies = {
    "nvim-java/lua-async-await",
    "nvim-java/nvim-java-core",
    "MunifTanjim/nui.nvim",
    "neovim/nvim-lspconfig",
    "nvim-java/nvim-java-test",
    "nvim-java/nvim-java-dap",
    "nvim-java/nvim-java-refactor",
  },
  ft = { "java" },
}

function M.config()
  require "java".setup {
    java_test = {
      enable = true,
    },
    java_debug_adapter = {
      enable = true,
    },
    jdk = {
      auto_install = false,
    },
    notifications = {
      dap = true,
    },
  }
end

return M
