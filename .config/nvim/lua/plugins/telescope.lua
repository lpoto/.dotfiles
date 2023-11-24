--=============================================================================
--                             https://github.com/nvim-telescope/telescope.nvim
--[[===========================================================================

Telescope is a highly extendable fuzzy finder over lists.
Items are shown in a popup with a prompt to search over.

Keymaps:
 - "<leader>n"   - find files
 - "<leader>o"   - old files
 - "<leader>l"   - live grep
 - "<leader>L"   - live grep word under cursor

 - "<leader>c"   - continue previous picker

 - "<leader>m"   - marks
 - "<leader>h"   - Search help tags

 - "<leader>d"   - show document diagnostics
 - "<leader>D"   - show workspace diagnostics
 - "gd"          - LSP definitions
 - "gi"          - LSP implementations
 - "gr"          - LSP references

 Use <C-q> in a telescope prompt to send the results to quickfix.
-----------------------------------------------------------------------------]]

local M = {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
}

local util = {}

function M.init()
  for _, o in ipairs {
    { 'n', '<leader>n', util.builtin 'find_files' },
    { 'n', '<leader>o', util.builtin 'oldfiles' },
    { 'n', '<leader>l', util.builtin 'live_grep' },
    { 'n', '<leader>L', util.builtin 'grep_string' },
    { 'n', '<leader>c', util.builtin 'resume' },
    { 'n', '<leader>m', util.builtin 'marks' },
    { 'n', '<leader>h', util.builtin 'help_tags' },
    { 'n', 'gd',        util.builtin 'lsp_definitions' },
    { 'n', 'gi',        util.builtin 'lsp_implementations' },
    { 'n', 'gr',        util.builtin 'lsp_references' },
    { 'n', '<leader>q', util.builtin('quickfix', true) },
    { 'n', '<leader>D', util.builtin 'diagnostics' },
    { 'n', '<leader>d', function()
      if not vim.diagnostic.open_float() then
        util.builtin 'diagnostics' { bufnr = 0 }
      end
    end
    },
  } do
    vim.keymap.set(unpack(o))
  end
end

function M.config()
  local telescope = require 'telescope'
  telescope.setup {
    defaults = {
      prompt_prefix = ' ',
      color_devicons = false,
      mappings = util.default_mappings(),
      sorting_strategy = 'ascending',
      layout_strategy = 'horizontal',
      selection_strategy = 'row',
      layout_config = {
        horizontal = {
          prompt_position = 'top',
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
        'plugged/',
        '%.undo/',
        '%.storage/',
        '%.data/',
        '%.local/',
        '%.git/',
        'node_modules/',
        'target/',
        '%.target/',
        '%.settings/',
        '%.build/',
        'generated/',
        'generated-sources/',
        '^build/',
        'dist/',
        '%.dist/',
        '%.angular/',
        '__pycache__/',
        'github.copilot/',
        '%.project$',
        '%.classpath$',
        '%.factorypath$',
        '%.jar$',
        '%.class$',
        '%.dll$',
        '%.jnilib$',
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
        selection_strategy = 'row',
      },
      git_status = {
        attach_mappings = util.attach_git_status_mappings,
        file_ignore_patterns = {},
        selection_strategy = 'row',
        initial_mode = 'normal',
      },
    },
  }
  require 'telescope'.load_extension 'fzf'

  vim.api.nvim_exec_autocmds('User', {
    pattern = 'TelescopeLoaded',
  })
end

function util.default_mappings()
  local actions = require 'telescope.actions'
  return {
    i = {
      -- NOTE: when a telescope window is opened, use ctrl + q to
      -- send the current results to a quickfix window, then immediately
      -- open quickfix in a telescope window
      ['<C-q>'] = function()
        actions.send_to_qflist(vim.fn.bufnr())
        util.builtin_l 'quickfix' ()
      end,
      ['<Tab>'] = actions.move_selection_next,
      ['<S-Tab>'] = actions.move_selection_previous,
    },
    n = {
      ['<Tab>'] = actions.move_selection_next,
      ['<S-Tab>'] = actions.move_selection_previous,
      ['<leader>j'] = function(bufnr)
        actions.move_selection_next(bufnr)
        actions.toggle_selection(bufnr)
      end,
      ['<leader>k'] = function(bufnr)
        actions.toggle_selection(bufnr)
        actions.move_selection_previous(bufnr)
      end,
    },
  }
end

function util.attach_git_status_mappings(_, map)
  local actions = require 'telescope.actions'
  actions.select_default:replace(actions.git_staging_toggle)
  map('n', 'e', actions.file_edit)
  map('i', '<C-e>', actions.file_edit)
  map('i', '<Tab>', actions.move_selection_next)
  map('n', '<Tab>', actions.move_selection_next)
  map('i', '<S-Tab>', actions.move_selection_previous)
  map('n', '<S-Tab>', actions.move_selection_previous)
  map('n', 's', actions.git_staging_toggle)
  map('i', '<C-s>', actions.git_staging_toggle)
  map('n', '<C-s>', actions.git_staging_toggle)
  return true
end

function util.attach_marks_mappings(_, map)
  local state = require 'telescope.actions.state'
  map({ 'n', 'i' }, '<C-r>', function()
    local entry = state.get_selected_entry()
    local display = vim.split(entry.display, ' ')
    local mark = display[1]
    local ok, _ = pcall(vim.api.nvim_del_mark, mark)
    if not ok then
      local err
      ok, err = pcall(vim.api.nvim_buf_del_mark, 0, mark)
      if not ok and type(err) == 'string' then
        vim.notify(err, vim.log.levels.WARN)
        return
      end
    end
    local picker = state.get_current_picker(vim.api.nvim_get_current_buf())
    if type(picker) == 'table' then picker:close_existing_pickers() end
    vim.schedule(function() require 'telescope_builtin'.marks() end)
  end)
  return true
end

function util.builtin(name, log_if_no_results)
  return function(opts)
    if type(opts) ~= 'table' then opts = {} end
    local telescope_builtin = require 'telescope.builtin'
    telescope_builtin[name](opts)
    if
      log_if_no_results == true
      and vim.api.nvim_get_option_value(
        'filetype',
        { buf = vim.api.nvim_get_current_buf() }
      )
      ~= 'TelescopePrompt'
    then
      vim.notify(
        '[telescope.builtin.' .. name .. '] Not results found ',
        vim.log.levels.WARN
      )
    end
  end
end

function util.builtin_l(name)
  return util.builtin(name, true)
end

return M
