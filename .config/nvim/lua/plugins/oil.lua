--=============================================================================
--                                         https://github.com/stevearc/oil.nvim
--[[===========================================================================

Keymaps:
 - "<leader>b"   - file browser relative to current file
 - "<leader>B"   - file browser relative to current working directory

 - "<C-q>"       - (in oil buffer) open quickfix list with all files in oil
                   buffer

-----------------------------------------------------------------------------]]
local M = {
  "stevearc/oil.nvim",
  commit = "bbad9a7",
  priority = 1000,
  lazy = false,
  cmd = "Oil",
  keys = {
    { "<leader>b", function() vim.cmd "Oil" end },
    { "<leader>B", function() vim.cmd("Oil " .. vim.fn.getcwd()) end },
    { "<C-n>",     function() vim.cmd "Oil" end },
  },
}

function M.config()
  local oil = require "oil"
  oil.setup {
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    buf_options = {
      buflisted = false,
      bufhidden = "wipe",
      swapfile = false,
    },
    win_options = {
      number = false,
      relativenumber = false,
    },
    view_options = {
      show_hidden = true,
    },
    columns = {},
    keymaps = {
      ["<BS>"] = "actions.parent",
      ["<C-q>"] = "actions.send_to_qflist",
      ["<CR>"] = { "actions.select", opts = { close = true } },
      ["<C-s>"] = { "actions.select", opts = { vertical = true, close = false } },
      ["<C-v>"] = { "actions.select", opts = { vertical = true, close = false } },
      ["<C-t>"] = { "actions.select", opts = { tab = true, close = false } },
      ["<C-h>"] = { "actions.select", opts = { horizontal = true, close = false } },
    },
  }

  if
    (
      vim.fn.argc() == 0
      or vim.fn.argc() == 1
      and vim.fn.isdirectory(
        vim.fn.expand(vim.fn.argv(0) --[[@as string]])
      )
      == 1
    )
    and #vim.api.nvim_list_bufs() == 1
    and vim.api.nvim_buf_line_count(0) == 0
    and vim.api.nvim_get_option_value("buftype", { buf = 0 }) == ""
    and vim.api.nvim_get_option_value("filetype", { buf = 0 }) == ""
  then
    oil.open()
  end
end

return M
