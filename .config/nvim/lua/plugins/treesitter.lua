--=============================================================================
-------------------------------------------------------------------------------
--                                                              NVIM-TREESITTER
--=============================================================================
-- https://github.com/nvim-treesitter/nvim-treesitter
--_____________________________________________________________________________

--[[
Treesitter interface for Neovim. Provides inproved
highlights, ...
--]]

local M = {
  "nvim-treesitter/nvim-treesitter",
  event = "VeryLazy",
}

function M.config()
  local treesitter = require "nvim-treesitter.configs"

  local parser_install_dir =
    table.concat({ vim.fn.stdpath "data", "treesitter" }, "/")
  vim.opt.runtimepath:append(parser_install_dir)

  treesitter.setup {
    parser_install_dir = parser_install_dir,
    ensure_installed = "all",
    --sync_install = true,
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = false,
    },
    -- incremental_selection = {
    --   enable = true,
    --   keymaps = {
    --     init_selection = "<leader>v",
    --     node_incremental = "<leader>v",
    --     scope_incremental = "<leader>v",
    --     node_decremental = "<A-v>",
    --   },
    -- },
  }
end

return M
