--=============================================================================
--                                       https://github.com/nvim-java/nvim-java
--=============================================================================
local M = {
  "nvim-java/nvim-java",
  tag = "v2.0.1",
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
