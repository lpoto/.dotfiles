--=============================================================================
--                                       https://github.com/nvim-java/nvim-java
--=============================================================================
local M = {
  "nvim-java/nvim-java",
  tag = "v1.7.0",
  ft = { "java" },
}

local util = {}

function M.config()
  util.fix_missing_hover_capabilities()

  require "java".setup {
    jdk = {
      auto_install = false,
    },
  }
end

--- clientHoverProvider = true causes the hover capability
--- to stop working, so we remove that option
function util.fix_missing_hover_capabilities()
  local jdtls_config = require "java-core.ls.servers.jdtls.config"
  local opts = jdtls_config.get_config()
  opts.init_options.extendedClientCapabilities.clientHoverProvider = nil
  jdtls_config.get_config = function()
    return opts
  end
end

return M
