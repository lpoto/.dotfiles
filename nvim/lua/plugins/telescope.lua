--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-TELESCOPE
--[[===========================================================================
https://github.com/nvim-telescope/telescope.nvim

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

local theme = "ivy"

function M.builtin(name, opts)
  return function()
    Util.require("telescope.builtin", function(builtin)
      builtin[name](opts)
    end)
  end
end

M.keys = {
  { "<leader>n", M.builtin "find_files", mode = "n" },
  { "<leader>b", M.builtin "buffers",    mode = "n" },
  {
    "<leader>B",
    M.builtin("buffers", { show_all_buffers = true }),
    mode = "n",
  },
  { "<leader>o",  M.builtin "oldfiles",     mode = "n" },
  { "<leader>q",  M.builtin "quickfix",     mode = "n" },
  { "<leader>d",  M.builtin "diagnostics",  mode = "n" },
  { "<leader>l",  M.builtin "live_grep",    mode = "n" },
  { "<leader>gg", M.builtin "git_status",   mode = "n" },
  { "<leader>gl", M.builtin "git_commits",  mode = "n" },
  { "<leader>gS", M.builtin "git_stash",    mode = "n" },
  { "<leader>gb", M.builtin "git_branches", mode = "n" },
}

function M.config()
  Util.require(
    { "telescope", "telescope.previewers" },
    function(telescope, previewers)
      telescope.setup {
        defaults = {
          prompt_prefix = "?  ",
          color_devicons = false,
          file_previewer = previewers.vim_buffer_cat.new,
          grep_previewer = previewers.vim_buffer_vimgrep.new,
          qflist_previewer = previewers.vim_buffer_qflist.new,
          mappings = M.default_mappings(),
        },
        pickers = M.pickers(),
      }
      require("telescope").load_extension "fzf"

      vim.api.nvim_exec_autocmds("User", {
        pattern = "TelescopeLoaded",
      })
    end
  )
end

function M.default_mappings()
  return Util.require(
    { "telescope.actions", "telescope.builtin" },
    function(actions, builtin)
      return {
        i = {
          -- NOTE: when a telescope window is opened, use ctrl + q to
          -- send the current results to a quickfix window, then immediately
          -- open quickfix in a telescope window
          ["<C-q>"] = function()
            actions.send_to_qflist(vim.fn.bufnr())
            builtin.quickfix()
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
  )
end

function M.pickers()
  local file_ignore_patterns = {
    Util.dir "plugged",
    Util.dir "%.undo",
    Util.dir "%.storage",
    Util.dir "%.data",
    Util.dir "%.local",
    Util.dir "%.git",
    Util.dir "node_modules",
    Util.dir "target",
    Util.dir "%.target",
    Util.dir "%.settings",
    Util.dir "%.build",
    Util.dir "dist",
    Util.dir "%.dist",
    Util.dir "build",
    Util.dir "%.build",
    Util.dir "%.angular",
    Util.dir "__pycache__",
    Util.dir "github.copilot",
    "%.project$",
    "%.classpath$",
    "%.factorypath$",
    "%.jar$",
    "%.class$",
    "%.dll$",
    "%.jnilib$",
  }
  return Util.require("telescope.actions", function(actions)
    return {
      find_files = {
        theme = theme,
        hidden = true,
        no_ignore = true,
        --previewer = true,
        file_ignore_patterns = file_ignore_patterns,
      },
      buffers = {
        theme = theme,
        sort_mru = true,
        ignore_current_buffer = false,
        show_all_buffers = false,
        sort_lastused = true,
        mappings = {
          i = {
            ["<c-d>"] = actions.delete_buffer,
          },
          n = {
            ["<c-d>"] = actions.delete_buffer,
            ["d"] = actions.delete_buffer,
          },
        },
      },
      oldfiles = {
        hidden = true,
        theme = theme,
        no_ignore = true,
      },
      diagnostics = {
        theme = theme,
      },
      live_grep = {
        hidden = true,
        no_ignore = true,
        theme = theme,
        file_ignore_patterns = file_ignore_patterns,
        additional_args = function()
          return { "--hidden", "-u" }
        end,
      },
      quickfix = {
        hidden = true,
        theme = theme,
        no_ignore = true,
        initial_mode = "normal",
      },
      git_status = {
        theme = theme,
        attach_mappings = M.attach_git_status_mappings,
        selection_strategy = "row",
        initial_mode = "normal",
      },
      git_branches = {
        theme = theme,
        selection_strategy = "row",
      },
      git_commits = {
        theme = theme,
        selection_strategy = "row",
      },
      git_stash = {
        theme = theme,
        selection_strategy = "row",
      },
    }
  end)
end

function M.attach_git_status_mappings(_, map)
  Util.require("telescope.actions", function(actions)
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
  end)
  return true
end

return M
