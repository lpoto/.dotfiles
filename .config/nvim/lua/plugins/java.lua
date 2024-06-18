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
  require "lspconfig".jdtls.setup {
    root_dir = function()
      local lspconfig = require "lspconfig"
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
