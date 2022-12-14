--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-TELESCOPE
--=============================================================================
-- https://github.com/nvim-telescope/telescope.nvim
--_____________________________________________________________________________

local plugin = require("plugin").new {
  "nvim-telescope/telescope.nvim",
  as = "telescope",
  keys = {
    "<leader>n", -- Open the Telescope Find Files
    "<leader>q", -- Open the Telescope Quickfix
    "<leader>d", -- Open the Telescope Diagnostics
    "<leader>g", -- Open the Telescope Live Grep
    "<C-n>", -- Open the Telescope File Explorer
    "<C-x>", -- Open the Telescope Live Grep For symbol under cursor
    "<C-g>", -- Open the Telescope Git Files
  },
  requires = {
    { "nvim-lua/plenary.nvim", module_pattern = { "plenary.*" } },
    {
      "nvim-telescope/telescope-file-browser.nvim",
      module_pattern = "telescope",
    },
  },
  config = function(telescope)
    telescope.setup {
      defaults = {
        file_sorter = require("telescope.sorters").get_fzy_sorter,
        prompt_prefix = "🔍",
        color_devicons = true,
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        mappings = {
          i = {
            -- NOTE: when a telescope window is oppened, use ctrl + q to
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
      },
      extensions = {
        file_browser = {
          theme = "ivy",
          hijack_netrw = true,
        },
      },
    }
    telescope.load_extension "file_browser"
  end,
}

---fuzzy find files with "<leader> + n"
---search word under cursor with "Ctrl + x"
---live grep with "<leader> + g" (REQUIRES 'ripgrep')
---open quickfix with "<leader> + q"
plugin:config(function()
  vim.api.nvim_set_keymap(
    "n",
    "<leader>n",
    "<cmd>lua require('telescope.builtin').find_files()<CR>",
    {
      silent = true,
      noremap = true,
    }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<leader>q",
    "<cmd>lua require('telescope.builtin').quickfix()<CR>",
    {
      silent = true,
      noremap = true,
    }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<leader>d",
    "<cmd>lua require('telescope.builtin').diagnostics()<CR>",
    {
      silent = true,
      noremap = true,
    }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<C-x>",
    "<cmd>lua require('telescope.builtin').grep_string()<CR>",
    {
      silent = true,
      noremap = true,
    }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<leader>g",
    "<cmd>lua require('telescope.builtin').live_grep()<CR>",
    {
      silent = true,
      noremap = true,
    }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<C-g>",
    "<cmd>lua require('telescope.builtin').git_files()<CR>",
    {
      silent = true,
      noremap = true,
    }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<C-n>",
    "<cmd>lua require('telescope').extensions.file_browser.file_browser()<CR>",
    { noremap = true }
  )
end)
