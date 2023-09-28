--=============================================================================
-------------------------------------------------------------------------------
--                                                                         JAVA
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end
local cache = vim.fn.stdpath("cache") .. "/jdtls/workspace" .. vim.fn.getcwd()

require("lsp"):attach({
  ---NOTE: Ensure you are using java 17 or above while using jdtls
  --NOTE: Clean up the cache directory from time to time
  name = "jdtls",
  cmd = { "jdtls", "-data", cache },
  settings = vim.g.jdtls_settings,
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
})
