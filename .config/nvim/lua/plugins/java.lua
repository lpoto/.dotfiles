--=============================================================================
--                                       https://github.com/nvim-java/nvim-java
--=============================================================================
local M = {
  "nvim-java/nvim-java",
  commit = "e552f06",
  dependencies = {
    { "nvim-java/nvim-java-core", tag = "v1.10.0" },
    { "nvim-java/nvim-java-dap", tag = "v1.0.0" },
    { "nvim-java/nvim-java-refactor", tag = "v1.7.0" },
    { "nvim-java/nvim-java-test", tag = "v1.0.1" },
  },
  ft = { "java" },
}

function M.config()
  require("java").setup {
    jdk = {
      auto_install = false,
    },
    jdtls = {
      version = "v1.44.0",
    },
    spring_boot_tools = {
      enable = false
    },
  }
end

return M
