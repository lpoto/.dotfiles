--=============================================================================
--                                                                FTPLUGIN-JAVA
--=============================================================================
if vim.g[vim.bo.filetype] then return end

vim.g[vim.bo.filetype] = function()
  return {
    language_server = {
      name = "jdtls",
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
    },
  }
end
