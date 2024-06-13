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
    --"mfussenegger/nvim-dap",
    {
      "williamboman/mason.nvim",
      opts = {
        registries = {
          "github:nvim-java/mason-registry",
          "github:mason-org/mason-registry",
        },
      },
    },
  },
  ft = { "java" },
}

function M.config()
  -- these  2 lines are a hack to avoid loading dap
  require "java.api.dap".setup_dap_on_lsp_attach = function() end
  require "java.startup.nvim-dep".check = function() end

  require "java".setup {
    java_test = {
      enable = false,
    },
    java_debug_adapter = {
      enable = false,
    },
    jdk = {
      auto_install = false,
    },
    notifications = {
      dap = false,
    },
  }
end

return M
