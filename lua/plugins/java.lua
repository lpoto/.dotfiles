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
  require("java.api.dap").setup_dap_on_lsp_attach = function() end
  require("java.startup.nvim-dep").check = function() end

  require("java").setup {
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
  local lspconfig = require "lspconfig"
  lspconfig.jdtls.setup {
    root_dir = function()
      local root_markers = {
        "settings.gradle",
        "settings.gradle.kts",
        "pom.xml",
        "build.gradle",
        "mvnw",
        "gradlew",
        "build.gradle",
        "build.gradle.kts",
        ".git",
      }
      local cwd = vim.fn.getcwd()
      local root_dir = lspconfig.util.root_pattern(unpack(root_markers))(cwd)
      if type(root_dir) ~= "string" or root_dir:len() == 0 then
        root_dir = lspconfig.util.root_pattern(unpack(root_markers))(
          vim.fn.expand "%:p:h"
        )
      end
      return root_dir or cwd
    end,
  }
end

return M
