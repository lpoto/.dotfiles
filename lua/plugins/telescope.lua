--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-TELESCOPE
--=============================================================================
-- https://github.com/nvim-telescope/telescope.nvim
--_____________________________________________________________________________

local telescope = require("util.packer_wrapper").get "telescope"

---Default setup for the telescope, sets default pickers and mappings
---for finding files(<leader>n), grep string(<C-x>), live grep (<leader>g)
---and git files(<C-g>)
---Send found elements to quickfix with <C-q>
---Open quickfix with <leader>q
telescope:config(function()
  require("telescope").setup {
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
  require("telescope").load_extension "file_browser"
end)

---fuzzy find files with "<leader> + n"
---search word under cursor with "Ctrl + x"
---live grep with "<leader> + g" (REQUIRES 'ripgrep')
---open quickfix with "<leader> + q"
telescope:config(function()
  local mapper = require "util.mapper"

  mapper.map(
    "n",
    "<leader>n",
    "<cmd>lua require('telescope.builtin').find_files()<CR>"
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
    "<C-x>",
    "<cmd>lua require('telescope.builtin').grep_string()<CR>"
  )
  mapper.map(
    "n",
    "<leader>g",
    "<cmd>lua require('telescope.builtin').live_grep()<CR>"
  )
  mapper.map(
    "n",
    "<C-g>",
    "<cmd>lua require('telescope.builtin').git_files()<CR>"
  )
  mapper.map(
    "n",
    "<C-n>",
    "<cmd>lua require('telescope').extensions.file_browser.file_browser()<CR>"
  )
end, "remappings")
