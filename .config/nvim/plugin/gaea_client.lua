-- GAEA CLIENT plugin

local cwd = vim.fn.getcwd()
if not cwd:match("/gaea%-client") then return end
local path = vim.split(cwd, "/gaea%-client")[1] .. "/gaea-client"

vim.g.jdtls_config = {
  settings = {
    java = {
      project = {
        referencedLibraries = {
          path .. "/platform/platform/**",
          path .. "/ext/build/**",
          path .. "/core/build/**",
          path .. "/data/build/**",
          path .. "/clusters/geom/build/**",
        },
      },
    },
  },
}
