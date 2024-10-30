--=============================================================================
--
--                             https://github.com/nvim-telescope/telescope.nvim
--[[===========================================================================

Telescope is a highly extendable fuzzy finder over lists.
Items are shown in a popup with a prompt to search over.

Keymaps:
 - "<leader><Space>"   - find files
 - "<leader>o"         - old files
 - "<leader>l"         - live grep
 - "<leader>L"         - live grep word under cursor

 - "<leader>c"         - continue previous picker

 - "<leader>m"         - marks
 - "<leader>h"         - Search help tags

 - "<leader>e"         - show document diagnostics, or on current line
 - "<leader>E"         - show workspace diagnostics
 - "gd"                - LSP definitions
 - "gi"                - LSP implementations
 - "gr"                - LSP references

 Use <C-q> in a telescope prompt to send the results to quickfix.
-----------------------------------------------------------------------------]]

local M = {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-ui-select.nvim",
  },
}

local util = {}

function M.init()
  for _, o in ipairs {
    { "n", "<leader><Space>", util.builtin "find_files" },
    { "n", "<leader>o",       util.builtin "oldfiles" },
    { "n", "<leader>l",       util.builtin "live_grep" },
    { "n", "<leader>L",       util.builtin "grep_string" },
    { "n", "<leader>c",       util.builtin "resume" },
    { "n", "<leader>m",       util.builtin "marks" },
    { "n", "<leader>h",       util.builtin "help_tags" },
    { "n", "gd",              util.builtin "lsp_definitions" },
    { "n", "gi",              util.builtin "lsp_implementations" },
    { "n", "gr",              util.builtin "lsp_references" },
    { "n", "<leader>q",       util.builtin("quickfix", { log = true }) },
    { "n", "<leader>E",       util.builtin "diagnostics" },
    {
      "n",
      "<leader>e",
      function()
        if not vim.diagnostic.open_float() then
          util.builtin "diagnostics" { bufnr = 0 }
        end
      end,
    },
  } do
    vim.keymap.set(unpack(o))
  end
  util.autocmds()
end

function M.config()
  local telescope = require "telescope"
  telescope.setup {
    defaults = {
      prompt_prefix = " ",
      dynamic_preview_title = true,
      path_display = util.path_display,
      color_devicons = false,
      disable_devicons = true,
      mappings = util.default_mappings(),
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      selection_strategy = "row",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.5,
          results_width = 1,
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
        "generated/",
        "generated-sources/",
        "^build/",
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
      marks = {
        attach_mappings = util.attach_marks_mappings,
        selection_strategy = "row",
      },
    },
    extensions = {
      ["ui-select"] = {
        require "telescope.themes".get_dropdown {},
      },
    },
  }
  require "telescope".load_extension "ui-select"
  require "telescope".load_extension "fzf"
end

function util.default_mappings()
  local actions = require "telescope.actions"
  return {
    i = {
      -- NOTE: when a telescope window is opened, use ctrl + q to
      -- send the current results to a quickfix window, then immediately
      -- open quickfix in a telescope window
      ["<C-q>"] = actions.send_to_qflist,
      ["<Tab>"] = actions.move_selection_next,
      ["<S-Tab>"] = actions.move_selection_previous,
      ["<C-s>"] = actions.toggle_selection,
      ["<C-a>"] = actions.toggle_all,
    },
    n = {
      ["s"] = actions.toggle_selection,
      ["<C-s>"] = actions.toggle_all,
      ["<C-a>"] = actions.select_all,
      ["<Tab>"] = actions.move_selection_next,
      ["<S-Tab>"] = actions.move_selection_previous,
    },
  }
end

function util.attach_marks_mappings(_, map)
  local state = require "telescope.actions.state"
  map({ "n", "i" }, "<C-r>", function()
    local entry = state.get_selected_entry()
    local display = vim.split(entry.display, " ")
    local mark = display[1]
    local ok, _ = pcall(vim.api.nvim_del_mark, mark)
    if not ok then
      local err
      ok, err = pcall(vim.api.nvim_buf_del_mark, 0, mark)
      if not ok and type(err) == "string" then
        vim.notify(err, vim.log.levels.WARN)
        return
      end
    end
    local picker = state.get_current_picker(vim.api.nvim_get_current_buf())
    if type(picker) == "table" then picker:close_existing_pickers() end
    vim.schedule(function() require "telescope.builtin".marks() end)
  end)
  return true
end

function util.autocmds()
  vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = vim.api.nvim_create_augroup("TelescopeQuickFix", { clear = true }),
    callback = function()
      vim.schedule(function()
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if
            vim.api.nvim_get_option_value("buftype", { buf = b })
            == "quickfix"
            and vim.fn.bufwinid(b) ~= -1
          then
            return
          end
        end
        return util.builtin("quickfix", true)()
      end)
    end,
  })
end

function util.builtin(name, o)
  if type(o) ~= "table" then o = {} end
  local log = o.log
  o.log = nil
  return function(opts)
    if type(opts) ~= "table" then opts = {} end
    opts = vim.tbl_extend("force", o, opts)
    local telescope_builtin = require "telescope.builtin"
    telescope_builtin[name](opts)
    if
      log == true
      and vim.api.nvim_get_option_value(
        "filetype",
        { buf = vim.api.nvim_get_current_buf() }
      )
      ~= "TelescopePrompt"
    then
      vim.notify(
        "[telescope.builtin." .. name .. "] Not results found ",
        vim.log.levels.WARN
      )
    end
  end
end

function util.path_display(_, path)
  local width = vim.api.nvim_win_get_width(0) - 3
  local path_parts = {}
  for part in string.gmatch(path, "[^/]+") do
    table.insert(path_parts, part)
  end

  local i = 1
  while path:len() > width do
    if i + 1 >= #path_parts then
      break
    end
    path_parts[i] = path_parts[i]:sub(1, 1)
    path = table.concat(path_parts, "/")
    i = i + 1
  end
  return path
end

function util.builtin_l(name) return util.builtin(name, true) end

return M
