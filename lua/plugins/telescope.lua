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
 - "<leader>tf"   - find files   (or <leader>n)
 - "<leader>to"   - old files
 - "<leader>tc"   - find neovim config files
 - "<leader>tb"   - file browser
 - "<leader>tg"   - live grep
 - "<leader>td"   - show diagnostics
 - "<leader>tq"   - quickfix

 Use <C-q> in a telescope prompt to send the results to quickfix.

NOTE:  telescope required rg (Ripgrep) and fd (Fd-Find) to be installed.
--]]

local M = {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
  },
}

function M.init()
  vim.keymap.set("n", "<leader>n", function()
    require("telescope.builtin").find_files()
  end)
  vim.keymap.set("n", "<leader>tf", function()
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
  vim.keymap.set("n", "<leader>tb", function()
    require("telescope").extensions.file_browser.file_browser()
  end)
  vim.keymap.set("n", "<leader>tc", function()
    require("plugins.telescope").neovim_config_files()
  end)
end

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
      mappings = M.default_mappings(),
    },
    pickers = M.pickers(),
    extensions = {
      file_browser = {
        theme = "ivy",
        hidden = true,
        hijack_netrw = true,
      },
    },
  }
  telescope.load_extension "file_browser"
end

---Find files in the neovim config directory.
function M.neovim_config_files()
  local builtin = require "telescope.builtin"
  builtin.find_files {
    prompt_title = "Neovim Config Files",
    hidden = true,
    cwd = vim.fn.stdpath "config",
  }
end

function M.pickers()
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
      previewer = false,
      file_ignore_patterns = {
        "plugged/",
        ".undo/",
        ".local/",
        ".git/",
        "node_modules/",
        "target/",
        ".settings/",
        "dist/",
        ".angular/",
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
    },
  }
end

function M.default_mappings()
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
    },
  }
end

return M
