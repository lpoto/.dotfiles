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

-- NOTE: jdtls required java 17 +
lspconfig.start_language_server("jdtls", {
  cmd = { "jdtls" },
  root_dir = function()
    local f = vim.fs.find({
      --"build.xml", -- Ant
      "pom.xml", -- Maven
      "settings.gradle", -- Gradle
      "settings.gradle.kts", -- Gradle
      "mvn", -- mvnw
      "build.gradle",
      "build.gradle.kts",
    }, { upward = true })
    if not f or not next(f) then
      -- Return "/" so only syntax errors are  reported
      return "/"
    end
    return vim.fs.dirname(f[1])
  end,
})

null_ls.register_formatter "clang_format"
