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
 - "<leader>L"   - live grep for word under cursor

 - "<leader>M"   - marks
 - "<leader>h"   - Search help tags

 - "<leader>d"   - show diagnostics
 - "gd"          - LSP definitions
 - "gr"          - LSP references

 - "<leader>gl"  - git commits
 - "<leader>gb"  - git branches
 - "<leader>gS"  - git stash
 - "<leader>gg" or "<leader>gs"  - git status

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

local function builtin(name, opts, log_if_no_results)
  return function()
    Util.require("telescope.builtin", function(telescope_builtin)
      telescope_builtin[name](opts)
      if
        log_if_no_results == true
        and vim.api.nvim_buf_get_option(
            vim.api.nvim_get_current_buf(),
            "filetype"
          )
          ~= "TelescopePrompt"
      then
        Util.log("Telescope")
          :warn("[telescope.builtin." .. name .. "] Not results found ")
      end
    end)
  end
end

M.keys = {
  { "<leader>n", builtin("find_files"), mode = "n" },
  { "<leader>b", builtin("buffers", nil, true), mode = "n" },
  {
    "<leader>B",
    builtin("buffers", { show_all_buffers = true }, true),
    mode = "n",
  },
  { "<leader>o", builtin("oldfiles"), mode = "n" },
  { "<leader>l", builtin("live_grep"), mode = "n" },
  { "<leader>L", builtin("grep_string"), mode = "n" },

  { "<leader>M", builtin("marks"), mode = "n" },
  { "<leader>h", builtin("help_tags"), mode = "n" },

  { "<leader>d", builtin("diagnostics"), mode = "n" },
  { "gd", builtin("lsp_definitions"), mode = "n" },
  { "gr", builtin("lsp_references"), mode = "n" },

  { "<leader>gg", builtin("git_status"), mode = "n" },
  { "<leader>gl", builtin("git_commits"), mode = "n" },
  { "<leader>gS", builtin("git_stash"), mode = "n" },
  { "<leader>gb", builtin("git_branches"), mode = "n" },
}

local default_mappings
local attach_git_status_mappings
local attach_marks_mappings

function M.config()
  Util.require(
    { "telescope", "telescope.actions" },
    function(telescope, actions)
      telescope.setup({
        defaults = {
          prompt_prefix = "?  ",
          color_devicons = false,
          mappings = default_mappings(),
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          selection_strategy = "row",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 200,
            height = 0.70,
            preview_cutoff = 120,
          },
          file_ignore_patterns = {
            Util.path():dir("plugged"),
            Util.path():dir("%.undo"),
            Util.path():dir("%.storage"),
            Util.path():dir("%.data"),
            Util.path():dir("%.local"),
            Util.path():dir("%.git"),
            Util.path():dir("node_modules"),
            Util.path():dir("target"),
            Util.path():dir("%.target"),
            Util.path():dir("%.settings"),
            Util.path():dir("%.build"),
            Util.path():dir("build"),
            Util.path():dir("dist"),
            Util.path():dir("%.dist"),
            Util.path():dir("%.angular"),
            Util.path():dir("__pycache__"),
            Util.path():dir("github.copilot"),
            "%.project$",
            "%.classpath$",
            "%.factorypath$",
            "%.jar$",
            "%.class$",
            "%.dll$",
            "%.jnilib$",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = true,
          },
          buffers = {
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
            no_ignore = true,
          },
          live_grep = {
            hidden = true,
            no_ignore = true,
            additional_args = function()
              return { "--hidden", "-u" }
            end,
          },
          grep_string = {
            hidden = true,
            no_ignore = true,
            additional_args = function()
              return { "--hidden", "-u" }
            end,
          },
          marks = {
            attach_mappings = attach_marks_mappings,
            selection_strategy = "row",
          },
          git_status = {
            attach_mappings = attach_git_status_mappings,
            selection_strategy = "row",
            initial_mode = "normal",
          },
        },
      })
      require("telescope").load_extension("fzf")

      vim.api.nvim_exec_autocmds("User", {
        pattern = "TelescopeLoaded",
      })
    end
  )
end

function default_mappings()
  return Util.require("telescope.actions", function(actions)
    return {
      i = {
        -- NOTE: when a telescope window is opened, use ctrl + q to
        -- send the current results to a quickfix window, then immediately
        -- open quickfix in a telescope window
        ["<C-q>"] = function()
          actions.send_to_qflist(vim.fn.bufnr())
          Util.misc().toggle_quickfix(nil, true)
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
  end)
end

function attach_git_status_mappings(_, map)
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

function attach_marks_mappings(_, map)
  Util.require("telescope.actions.state", function(state)
    map({ "n", "i" }, "<C-r>", function()
      local entry = state.get_selected_entry()
      local display = vim.split(entry.display, " ")
      local mark = display[1]
      local ok, _ = pcall(vim.api.nvim_del_mark, mark)
      if not ok then
        local err
        ok, err = pcall(vim.api.nvim_buf_del_mark, 0, mark)
        if not ok then
          Util.log():warn(err)
          return
        end
      end
      local picker = state.get_current_picker(vim.api.nvim_get_current_buf())
      if type(picker) == "table" then
        picker:close_existing_pickers()
      end
      vim.schedule(function()
        Util.require("telescope.builtin", function(telescope_builtin)
          telescope_builtin.marks()
        end)
      end)
    end)
  end)
  return true
end

return M
