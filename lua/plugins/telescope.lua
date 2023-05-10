--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-TELESCOPE
--=============================================================================
-- https://github.com/nvim-telescope/telescope.nvim
--[[___________________________________________________________________________

Telescope is a highly extendable fuzzy finder over lists.
Items are shown in a popup with a prompt to search over.

Keymaps:
 - "<leader>n"   - find files   (or <leader>n)
 - "<leader>b"   - buffers
 - "<leader>o"   - old files
 - "<leader>l"   - live grep
 - "<leader>d"   - show diagnostics
 - "<leader>q"   - quickfix

 - "<leader>gl"  - git commits
 - "<leader>gb"  - git branches
 - "<leader>gS"  - git stash
 - "<leader>gg"  - git status

 Use <C-q> in a telescope prompt to send the results to quickfix.
-----------------------------------------------------------------------------]]
local M = {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
}

M.theme = "ivy"

function M.builtin(name)
  return function()
    require("telescope.builtin")[name]()
  end
end

M.keys = {
  { "<leader>n", M.builtin "find_files", mode = "n" },
  { "<leader>b", M.builtin "buffers", mode = "n" },
  { "<leader>o", M.builtin "oldfiles", mode = "n" },
  { "<leader>q", M.builtin "quickfix", mode = "n" },
  { "<leader>d", M.builtin "diagnostics", mode = "n" },
  { "<leader>l", M.builtin "live_grep", mode = "n" },
  { "<leader>gg", M.builtin "git_status", mode = "n" },
  { "<leader>gl", M.builtin "git_commits", mode = "n" },
  { "<leader>gS", M.builtin "git_stash", mode = "n" },
  { "<leader>gb", M.builtin "git_branches", mode = "n" },
}

function M.config()
  local telescope = require "telescope"

  telescope.setup {
    defaults = {
      prompt_prefix = "?  ",
      color_devicons = false,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      mappings = M.default_mappings(),
    },
    pickers = M.pickers(),
  }
  telescope.load_extension "fzf"
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

function M.pickers()
  local util = require "config.util"
  local file_ignore_patterns = {
    util.dir "plugged",
    util.dir "%.undo",
    util.dir "%.storage",
    util.dir "%.data",
    util.dir "%.local",
    util.dir "%.git",
    util.dir "node_modules",
    util.dir "target",
    util.dir "%.target",
    util.dir "%.settings",
    util.dir "%.build",
    util.dir "dist",
    util.dir "%.dist",
    util.dir "build",
    util.dir "%.build",
    util.dir "%.angular",
    util.dir "__pycache__",
    util.dir "github.copilot",
    "%.jar$",
    "%.class$",
    "%.dll$",
    "%.jnilib$",
  }
  return {
    find_files = {
      theme = M.theme,
      hidden = true,
      no_ignore = true,
      --previewer = true,
      file_ignore_patterns = file_ignore_patterns,
    },
    buffers = {
      theme = M.theme,
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
      theme = M.theme,
      no_ignore = true,
    },
    diagnostics = {
      theme = M.theme,
    },
    live_grep = {
      hidden = true,
      no_ignore = true,
      theme = M.theme,
      file_ignore_patterns = file_ignore_patterns,
      additional_args = function()
        return { "--hidden" }
      end,
    },
    quickfix = {
      hidden = true,
      theme = M.theme,
      no_ignore = true,
      initial_mode = "normal",
    },
    git_status = {
      theme = M.theme,
      attach_mappings = M.attach_git_status_mappings,
      selection_strategy = "row",
      initial_mode = "normal",
    },
    git_branches = {
      theme = M.theme,
      selection_strategy = "row",
    },
    git_commits = {
      theme = M.theme,
      selection_strategy = "row",
    },
    git_stash = {
      theme = M.theme,
      selection_strategy = "row",
    },
  }
end

function M.attach_git_status_mappings(_, map)
  local actions = require "telescope.actions"
  actions.select_default:replace(actions.git_staging_toggle)
  map("n", "e", actions.file_edit)
  map("i", "<C-e>", actions.file_edit)
  map("i", "<Tab>", actions.move_selection_next)
  map("i", "<Tab>", actions.move_selection_next)
  map("n", "<Tab>", actions.move_selection_next)
  map("i", "<S-Tab>", actions.move_selection_previous)
  map("n", "<S-Tab>", actions.move_selection_previous)
  map("n", "s", actions.git_staging_toggle)
  map("i", "<C-s>", actions.git_staging_toggle)
  map("n", "<C-s>", actions.git_staging_toggle)
  return true
end

return M
