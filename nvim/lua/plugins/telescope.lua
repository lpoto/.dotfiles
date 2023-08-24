--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-TELESCOPE
--[[===========================================================================
https://github.com/nvim-telescope/telescope.nvim

Telescope is a highly extendable fuzzy finder over lists.
Items are shown in a popup with a prompt to search over.

Keymaps:
 - "<leader>t"    - find files
 - "<leader>to"   - old files
 - "<leader>tg"   or "<leader>tl"                 - live grep
 - "<leader>tG" or "<leader>tL" or "<leader>tw"   - live grep word under cursor

 - "<leader>tm"   - marks
 - "<leader>th"   - Search help tags

 - "ge"          - show diagnostics
 - "gd"          - LSP definitions
 - "gr"          - LSP references

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
  { "<leader>t", builtin("find_files"), mode = "n" },
  { "<leader>tf", builtin("find_files"), mode = "n" },
  { "<leader>to", builtin("oldfiles"), mode = "n" },
  { "<leader>tg", builtin("live_grep"), mode = "n" },
  { "<leader>tl", builtin("live_grep"), mode = "n" },
  { "<leader>tG", builtin("grep_string"), mode = "n" },
  { "<leader>tL", builtin("grep_string"), mode = "n" },
  { "<leader>tw", builtin("grep_string"), mode = "n" },

  { "<leader>tm", builtin("marks"), mode = "n" },
  { "<leader>th", builtin("help_tags"), mode = "n" },

  { "ge", builtin("diagnostics"), mode = "n" },
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
  Util.require("telescope", function(telescope)
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
          "plugged/",
          "%.undo/",
          "%.storage/",
          "%.data/",
          "%.local/",
          "%.git/",
          "node_modules/",
          "target/",
          "%.target/",
          "%.settings/",
          "%.build/",
          "build/",
          "dist/",
          "%.dist/",
          "%.angular/",
          "__pycache__/",
          "github.copilot/",
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
        oldfiles = {
          hidden = true,
          no_ignore = true,
        },
        live_grep = {
          hidden = true,
          no_ignore = true,
          additional_args = function() return { "--hidden", "-u" } end,
        },
        grep_string = {
          hidden = true,
          no_ignore = true,
          additional_args = function() return { "--hidden", "-u" } end,
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
  end)
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
      if type(picker) == "table" then picker:close_existing_pickers() end
      vim.schedule(function()
        Util.require(
          "telescope.builtin",
          function(telescope_builtin) telescope_builtin.marks() end
        )
      end)
    end)
  end)
  return true
end

return M
