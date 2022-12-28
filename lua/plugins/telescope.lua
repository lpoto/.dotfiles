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
 - "<leader>n"   - find files
 - "<leader>m"   - old files
 - "<leader>c"   - find neovim config files
 - "<C-n>"       - file explorer
 - "<leader>g"   - live grep
 - "<leader>d"   - show diagnostics
 - "<leader>q"   - quickfix

 Use <C-q> in a telescope prompt to send the results to quickfix.

NOTE:  telescope required rg (Ripgrep) and fd (Fd-Find) to be installed.
--]]

local M = {
  "nvim-telescope/telescope.nvim",
  keys = {
    "<leader>n",
    "<leader>m",
    "<C-n>",
    "<leader>q",
    "<leader>d",
    "<leader>g",
  },
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
  },
}

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
      mappings = {
        i = {
          -- NOTE: when a telescope window is opened, use ctrl + q to
          -- send the current results to a quickfix window, then immediately
          -- open quickfix in a telescope window
          ["<C-q>"] = function()
            require("telescope.actions").send_to_qflist(vim.fn.bufnr())
            require("telescope.builtin").quickfix()
          end,
        },
      },
    },
    pickers = {
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
    },
    extensions = {
      file_browser = {
        theme = "ivy",
        hidden = true,
        hijack_netrw = true,
      },
    },
  }
  telescope.load_extension "file_browser"

  local mapper = require "util.mapper"

  mapper.map(
    "n",
    "<leader>n",
    "<cmd>lua require('telescope.builtin').find_files()<CR>"
  )
  mapper.map(
    "n",
    "<leader>m",
    "<cmd>lua require('telescope.builtin').oldfiles()<CR>"
  )
  mapper.map(
    "n",
    "<leader>q",
    "<cmd>lua require('telescope.builtin').quickfix()<CR>"
  )
  mapper.map(
    "n",
    "<leader>d",
    "<cmd>lua require('telescope.builtin').diagnostics()<CR>"
  )
  mapper.map(
    "n",
    "<leader>g",
    "<cmd>lua require('telescope.builtin').live_grep()<CR>"
  )
  mapper.map(
    "n",
    "<C-n>",
    "<cmd>lua require('telescope').extensions.file_browser.file_browser()<CR>"
  )
  mapper.map(
    "n",
    "<leader>c",
    "<cmd>lua require('plugins.telescope').neovim_config_files()<CR>"
  )
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

return M
