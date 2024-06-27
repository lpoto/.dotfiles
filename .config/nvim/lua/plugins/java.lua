--=============================================================================
--                                       https://github.com/nvim-java/nvim-java
--=============================================================================
local M = {
  "nvim-java/nvim-java",
  dependencies = {
    "nvim-java/lua-async-await",
    "nvim-java/nvim-java-refactor",
    "nvim-java/nvim-java-core",
    "nvim-java/nvim-java-test",
    "nvim-java/nvim-java-dap",
    "MunifTanjim/nui.nvim",
  },
  ft = { "java" },
}

function M.config()
  require "java".setup {
    jdk = {
      auto_install = false,
    },
  }
end

return M
