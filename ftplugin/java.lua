--=============================================================================
-------------------------------------------------------------------------------
--                                                                         JAVA
--[[===========================================================================
Loaded when a java file is opened
-----------------------------------------------------------------------------]]
require("config.util").ftplugin {
  formatter = "google_java_format",
  language_server = {
    "jdtls",
    ---NOTE: Ensure you are using java 17 or above while using jdtls, as
    ---    it is not compatible with lower versions.
    ---
    ---     Make sure to often clean the workspace, and java and jdtls
    ---     cache (check ~/.jdtls and ~/.cache, ....) to prevent jdtls
    ---     from crashing.
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
    --[[

    NOTE: jdtls will work fine with gradle and maven, but it might
          not work with ant or other older build tools.

          As a workaround, you may add something similar to a project's
          local config:

          vim.g.jdtls_config = {
            settings = {
              java = {
                project = {
                  referencedLibraries = {
                    "/path_to_project/lib/**",
                  }
                }
              }
            }
          }
    --]]
  },
}
