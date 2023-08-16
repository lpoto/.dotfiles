--=============================================================================
-------------------------------------------------------------------------------
--                                                                         JAVA
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

vim.b.formatter = function()
  return {
    exe = "google-java-format",
    args = { "--aosp", vim.api.nvim_buf_get_name(0), "--replace" },
    stdin = true,
  }
end
vim.b.language_server = {
  name = "jdtls",
  ---NOTE: Ensure you are using java 17 or above while using jdtls, as
  ---    it is not compatible with lower versions.
  ---
  ---     Make sure to often clean the workspace, and java and jdtls
  ---     cache (vim.fn.stdpath("cache") .. "/jdtls") to prevent jdtls
  ---     from crashing.
  cmd = {
    "jdtls",
    "-data",

    vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. vim.fn.getcwd(),
  },
  root_patterns = {
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
}
