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

local null_ls = require "plugins.null-ls"
null_ls.register_formatter "clang_format"

local lspconfig = require "plugins.lspconfig"
local util = require "config.util"
local get_jars_to_include

---NOTE: Ensure you are using java 17 or above while using jdtls, as
---    it is not compatible with lower versions.
---
---     Make sure to often clean the workspace, and java and jdtls
---     cache (check ~/.jdtls and ~/.cache, ....) to prevent jdtls
---     from crashing.
local function start_jdtls()
  local root_dir = util.root_fn {
    "build.xml",
    "pom.xml",
    "mvn",
    "settings.gradle",
    "settings.gradle.kts",
    "gradlew",
    "build.gradle",
    "build.gradle.kts",
    ".git",
  }
  lspconfig.start_language_server("jdtls", {
    cmd = { "jdtls" },
    root_dir = root_dir,
    settings = {
      java = {
        project = {
          referencedLibraries = get_jars_to_include(root_dir),
        },
      },
    },
  })
end

--- Search for build, lib, target, dist directories in
--- the root directory, and add include the jars in
--- those directories in the jdtls settings.
--- NOTE: this is a workaround for jdtls not being able
---    to find jars in those directories when using ant
---    or something similar.
---    This should not be needed with gradle and maven
---    builds.
--- TODO:  disable this for gradle and maven builds.
function get_jars_to_include(root_fn)
  local jars_to_add = vim.fs.find({
    "build",
    "lib",
    "target",
    "dist",
  }, {
    root = root_fn(),
    type = "directory",
    upward = false,
    limit = math.huge,
  }) or {}
  for k, v in pairs(jars_to_add) do
    local jar = util.path(v, "**", "*.jar")
    jars_to_add[k] = jar
  end
  return jars_to_add
end

vim.schedule(start_jdtls)
