--=============================================================================
-------------------------------------------------------------------------------
--                                                                         RUBY
--=============================================================================
-- Loaded when a ruby file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- LSPCONFIG
-- NOTE: set solargraph the default lsp server for ruby

require("plugins.lspconfig").distinct_setup("ruby", function()
  -- gem install solargraph
  require("lspconfig").solargraph.setup {
    capabilities = require("plugins.cmp").default_capabilities(),
    root_dir = require("util").get_root,
  }
  -- NOTE: Start the lsp server
  vim.fn.execute("LspStart", true)
end)

--------------------------------------------------------------------- FORMATTER
-- NOTE: set rubocop as the default formatter for ruby

require("plugins.formatter").distinct_setup("ruby", {
  filetype = {
    ruby = {
      function()
        -- gem install rubocop
        local util = require "formatter.util"
        return {
          exe = "rubocop",
          args = {
            "--fix-layout",
            "--stdin",
            util.escape_path(util.get_current_buffer_file_name()),
            "--format",
            "files",
          },
          stdin = true,
          transform = function(text)
            table.remove(text, 1)
            table.remove(text, 1)
            return text
          end,
        }
      end,
    },
  },
})

--------------------------------------------------------------------- DEBUGGER
-- NOTE: set readapt as default ruby debugger

require("plugins.dap").distinct_setup("ruby", function(dap)
  -- gem install readapt

  dap.adapters.ruby = {
    type = "executable",
    command = "readapt",
    args = { "stdio" },
  }
  -- this config launches the currently oppened ruby file

  -- NOTE: debug currently oppened file with readapt

  dap.configurations.ruby = {
    {
      type = "ruby",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      useBundler = false,
    },
  }
end)

----------------------------------------------------------------------- ACTIONS
-- NOTE: set default actions

require("plugins.actions").distinct_setup("ruby", {
  actions = {
    -- Run currently oppened ruby file
    run_current_ruby_file = function()
      return {
        filetypes = { "ruby" },
        steps = {
          { "ruby", vim.fn.expand "%:p" },
        },
      }
    end,
  },
})
