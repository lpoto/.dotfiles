--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-TELESCOPE
--=============================================================================
-- https://github.com/nvim-telescope/telescope.nvim
--_____________________________________________________________________________

--[[

Telescope is a highly extendable fuzzy finder over lists.
Items are shown in a popup with a prompt to search over.

Keymaps:
 - "<leader>t"   - find files   (or <leader>n)
 - "<leader>to"   - old files
 - "<leader>tg"   - live grep
 - "<leader>td"   - show diagnostics
 - "<leader>tq"   - quickfix

 Use <C-q> in a telescope prompt to send the results to quickfix.
NOTE: 
  see 
  -  lua/plugins/telescope/tasks.lua
  -  lua/plugins/telescope/undo.lua
  -  lua/plugins/telescope/file_browser.lua
  -  lua/plugins/telescope/docker.lua
  -  lua/plugins/telescope/git.lua

NOTE:  telescope required rg (Ripgrep) and fd (Fd-Find) to be installed.
--]]
--
local M = {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
}
local _M = {
  M,
  require "plugins.telescope.undo",
  require "plugins.telescope.tasks",
  require "plugins.telescope.file_browser",
  require "plugins.telescope.docker",
  "nvim-lua/plenary.nvim",
}

function M.init()
  vim.keymap.set("n", "<leader>n", function()
    require("telescope.builtin").find_files()
  end)
  vim.keymap.set("n", "<leader>t", function()
    require("telescope.builtin").find_files()
  end)
  vim.keymap.set("n", "<leader>to", function()
    require("telescope.builtin").oldfiles()
  end)
  vim.keymap.set("n", "<leader>tq", function()
    require("telescope.builtin").quickfix()
  end)
  vim.keymap.set("n", "<leader>td", function()
    require("telescope.builtin").diagnostics()
  end)
  vim.keymap.set("n", "<leader>tg", function()
    require("telescope.builtin").live_grep()
  end)
  require("plugins.telescope.git").init()
end

local default_mappings
local pickers

function M.config()
  local telescope = require "telescope"

  telescope.setup {
    defaults = {
      file_sorter = require("telescope.sorters").get_fzy_sorter,
      generic_sorter = require("telescope.sorters").get_fzy_sorter,
      prompt_prefix = "🔍",
      color_devicons = true,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      mappings = default_mappings(),
    },
    pickers = pickers(),
  }
end

default_mappings = function()
  local actions = require "telescope.actions"
  return {
    i = {
      -- NOTE: when a telescope window is opened, use ctrl + q to
      -- send the current results to a quickfix window, then immediately
      -- open quickfix in a telescope window
      ["<C-q>"] = function()
        require("telescope.actions").send_to_qflist(vim.fn.bufnr())
        require("telescope.builtin").quickfix()
      end,
      ["<Tab>"] = actions.move_selection_next,
      ["<S-Tab>"] = actions.move_selection_previous,
    },
    n = {
      ["<Tab>"] = actions.move_selection_next,
      ["<S-Tab>"] = actions.move_selection_previous,
      ["<leader>j"] = function(bufnr)
        actions.move_selection_next(bufnr)
        actions.toggle_selection(bufnr)
      end,
      ["<leader>k"] = function(bufnr)
        actions.toggle_selection(bufnr)
        actions.move_selection_previous(bufnr)
      end,
    },
  }
end

pickers = function()
  return {
    find_files = {
      find_command = {
        "rg",
        "--files",
        "--iglob",
        "!.git",
        "--hidden",
        "-u",
      },
      theme = "ivy",
      hidden = true,
      --previewer = true,
      file_ignore_patterns = {
        "plugged/",
        "\\.undo/",
        ".local/",
        "\\.git/",
        "node_modules/",
        "target/",
        "\\.settings/",
        "dist/",
        "\\.angular/",
        "__pycache__",
      },
    },
    oldfiles = {
      hidden = true,
      theme = "ivy",
    },
    live_grep = {
      hidden = true,
      theme = "ivy",
    },
    quickfix = {
      hidden = true,
      theme = "ivy",
      initial_mode = "normal",
    },
  }
end

return _M
