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
 - "<leader>n"   - find files   (or <leader>n)
 - "<leader>b"   - buffers
 - "<leader>o"   - old files
 - "<leader>l"   - live grep
 - "<leader>d"   - show diagnostics
 - "<leader>q"   - quickfix

 Use <C-q> in a telescope prompt to send the results to quickfix.
--]]
--
local M = {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}

M.keys = {
  {
    "<leader>n",
    function()
      require("telescope.builtin").find_files()
    end,
    mode = "n",
  },
  {
    "<leader>b",
    function()
      require("telescope.builtin").buffers()
    end,
    mode = "n",
  },
  {
    "<leader>o",
    function()
      require("telescope.builtin").oldfiles()
    end,
    mode = "n",
  },
  {
    "<leader>q",
    function()
      require("telescope.builtin").quickfix()
    end,
    mode = "n",
  },
  {
    "<leader>d",
    function()
      require("telescope.builtin").diagnostics()
    end,
    mode = "n",
  },
  {
    "<leader>l",
    function()
      require("telescope.builtin").live_grep()
    end,
    mode = "n",
  },
}

local default_mappings
local pickers

function M.config()
  local telescope = require "telescope"

  telescope.setup {
    defaults = {
      file_sorter = require("telescope.sorters").get_fzy_sorter,
      generic_sorter = require("telescope.sorters").get_fzy_sorter,
      prompt_prefix = "?  ",
      color_devicons = false,
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
  local file_ignore_patterns = {
    "plugged/",
    "%.undo/",
    "%.data/",
    "%.local/",
    "%.git/",
    "node_modules/",
    "target/",
    "%.target/",
    "%.settings/",
    "%.build/",
    "dist/",
    "%.dist/",
    "%.angular/",
    "__pycache__",
    "github-copilot",
    "%.github-copilot",
  }
  return {
    find_files = {
      theme = "ivy",
      hidden = true,
      no_ignore = true,
      --previewer = true,
      file_ignore_patterns = file_ignore_patterns,
    },
    buffers = {
      theme = "ivy",
      sort_mru = true,
      ignore_current_buffer = false,
      mappings = {
        i = {
          ["<c-d>"] = require("telescope.actions").delete_buffer,
        },
        n = {
          ["<c-d>"] = require("telescope.actions").delete_buffer,
          ["d"] = require("telescope.actions").delete_buffer,
        },
      },
    },
    oldfiles = {
      hidden = true,
      theme = "ivy",
      no_ignore = true,
    },
    live_grep = {
      hidden = true,
      no_ignore = true,
      theme = "ivy",
      file_ignore_patterns = file_ignore_patterns,
      additional_args = function()
        return { "--hidden" }
      end,
    },
    quickfix = {
      hidden = true,
      theme = "ivy",
      no_ignore = true,
      initial_mode = "normal",
    },
  }
end

return M
