local M = {
  "mfussenegger/nvim-jdtls",
}

function M.config()
  local config = {
    cmd = { "jdtls" },
    root_dir = vim.fs.dirname(
      vim.fs.find({ ".gradlew", ".git", "mvnw" }, { upward = true })[1]
    ),
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
  }
  require("jdtls").start_or_attach(config)
end

return M
