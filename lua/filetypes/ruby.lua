--=============================================================================
-------------------------------------------------------------------------------
--                                                                         RUBY
--=============================================================================
-- Loaded when a ruby file is oppened.
--_____________________________________________________________________________

--------------------------------------------------------------------- LSPCONFIG
--github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#solargraph

-- NOTE: set solargraph the default lsp server for ruby
local lspconfig = require("util.packer.wrapper").get "lspconfig"

lspconfig:config(function()
  --[[
      gem install solargraph
  ]]
  require("lspconfig").solargraph.setup {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    root_dir = require "util.root",
  }
  -- NOTE: Start the lsp server
  vim.fn.execute("LspStart", true)
end, "ruby")

vim.cmd "LspStart"

------------------------------------------------------------------------ LINTER
--https://github.com/mfussenegger/nvim-lint
--
local lint = require("util.packer.wrapper").get "lint"

--NOTE: lint ruby with rubocop
--[[
    gem install rubocop
]]
lint:config(function()
  require("lint").linters_by_ft["ruby"] = { "rubocop" }
end, "ruby")

--------------------------------------------------------------------- FORMATTER
--github.com/mhartington/formatter.nvim/blob/master/lua/formatter/filetypes/ruby.lua
--
local formatter = require("util.packer.wrapper").get "formatter"

-- NOTE: set rubocop as the default formatter for ruby
formatter:config(function()
  --[[
      gem install rubocop
  ]]
  require("formatter").setup {
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
  }
end, "ruby")

--------------------------------------------------------------------- DEBUGGER
--https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#Ruby

local dap = require("util.packer.wrapper").get "dap"

-- NOTE: set readapt as default ruby debugger

dap:config(function()
  --[[  
      gem install readapt
  ]]
  require("dap").adapters.ruby = {
    type = "executable",
    command = "readapt",
    args = { "stdio" },
    options = {
      detach = false,
    },
  }
end, "ruby_adapter")

-- this config launches the currently oppened ruby file
dap:config(function()
  require("dap").configurations.ruby = {
    {
      type = "ruby",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      useBundler = false,
    },
  }
end, "ruby_debugger")

----------------------------------------------------------------------- ACTIONS
-- NOTE: set default actions

local actions = require("util.packer.wrapper").get "actions"

actions:config(function()
  require("actions").setup {
    actions = {
      -- Run currently oppened ruby file
      ["Run current Ruby file"] = function()
        return {
          filetypes = { "ruby" },
          steps = {
            { "ruby", vim.fn.expand "%:p" },
          },
        }
      end,
    },
  }
end, "ruby")

----------------------------------------------------------------------- COPILOT
-- NOTE: enable copilot for ruby

local copilot = require("util.packer.wrapper").get "copilot"

copilot:get_field "enable"()
