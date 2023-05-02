--=============================================================================
-------------------------------------------------------------------------------
--                                                                         JAVA
--[[===========================================================================
Loaded when a java file is opened
-----------------------------------------------------------------------------]]
if vim.g.ftplugin_java_loaded then
  return
end
vim.g.ftplugin_java_loaded = true

local lspconfig = require "plugins.lspconfig"
local null_ls = require "plugins.null-ls"

-- NOTE: Ensure you are using java 17 or above while using jdtls, as
--      it is not compatible with lower versions.
--
--      Make sure to often clean the workspace, and java and jdtls
--      cache (check ~/.jdtls and ~/.cache, ....) to prevent jdtls
--      from crashing.
lspconfig.start_language_server("jdtls", {
  cmd = { "jdtls" },
  root_dir = require("config.util").root_fn {
    "build.xml",
    "pom.xml",
    "mvn",
    "settings.gradle",
    "settings.gradle.kts",
    "gradlew",
    "build.gradle",
    "build.gradle.kts",
    ".git",
  },
})

null_ls.register_formatter "clang_format"
