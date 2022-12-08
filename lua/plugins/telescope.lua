--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-TELESCOPE
--=============================================================================
-- https://github.com/nvim-telescope/telescope.nvim
--_____________________________________________________________________________

local M = {}

---Default setup for the telescope, sets default pickers and mappings
---for finding files(<leader>n), grep string(<C-x>), live grep (<leader>g)
---and git files(<C-g>)
---Send found elements to quickfix with <C-q>
function M.init()
  require("telescope").setup {
    defaults = {
      file_sorter = require("telescope.sorters").get_fzy_sorter,
      prompt_prefix = "🔍",
      color_devicons = true,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
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
        file_ignore_patterns = M.pickers_ignore_patterns(),
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
  M.remappings()
end

---fuzzy find files with "<leader> + n"
---search word under cursor with "Ctrl + x"
---live grep with "<leader> + g" (REQUIRES 'ripgrep')
function M.remappings()
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
end

function M.pickers_ignore_patterns()
  local fi_patterns = {
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
  }
  return fi_patterns
end

return M
