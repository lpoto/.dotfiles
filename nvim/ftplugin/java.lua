--=============================================================================
-------------------------------------------------------------------------------
--                                                                         JAVA
--[[===========================================================================
Loaded when a java file is opened
-----------------------------------------------------------------------------]]
local root_fn = Util.misc().root_fn({
  "build.xml",
  "pom.xml",
  "mvn",
  "settings.gradle",
  "settings.gradle.kts",
  "gradlew",
  "build.gradle",
  "build.gradle.kts",
  ".git",
})

Util.ftplugin()
  :new()
  :attach_formatter("clangformat", { "-style=file" })
  :attach_language_server("jdtls", {
    ---NOTE: Ensure you are using java 17 or above while using jdtls, as
    ---    it is not compatible with lower versions.
    ---
    ---     Make sure to often clean the workspace, and java and jdtls
    ---     cache (vim.fn.stdpath("cache") .. "/jdtls") to prevent jdtls
    ---     from crashing.
    cmd = {
      "jdtls",
      "-data",
      Util.path()
        :new(vim.fn.stdpath("cache"), "jdtls", "workspace", root_fn()),
    },
    root_dir = root_fn,
    --[[

    NOTE: jdtls will work fine with gradle and maven, but it might
          not work with ant or other older build tools.

          As a workaround, you may add something similar to a project's
          local config to manually add the required libraries:

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
  })
