--=============================================================================
-------------------------------------------------------------------------------
--                                                                         JAVA
--=============================================================================
-- Loaded when a java file is opened.
-- Install required servers, linters and formatters with:
--
--                        :MasonInstall <pkg>   (or :Mason)
--
-- To see available linters and formatters for current filetype, run:
--
--                        :NullLsInfo
--
-- To see attached language server for current filetype, run:
--
--                        :LspInfo
--_____________________________________________________________________________

local filetype = require "filetype"

filetype.config {
  filetype = "java",
  priority = 1,
  copilot = true,
  formatter = "clang_format",
  language_server = {
    "jdtls",
    {
      root_dir = function()
        return require "root" { "pom.xml", ".git", "mvnw", ".gradlew" }
      end,
      cmd = {
        "jdtls",
        "-configuration",
        os.getenv "HOME" .. "/.cache",
        "-data",
        os.getenv "HOME" .. "/.jdtls",
      },
    },
  },
}

filetype.load "java"
