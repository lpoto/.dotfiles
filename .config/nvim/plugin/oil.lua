--=============================================================================
--                                                                          OIL
--[[===========================================================================

Oil is a file explorer that allows you to edit files and directories
in the same way,
and provides a familiar interface for navigating the file system.

This means the file tree can be edited just like any other buffer,
and all the usual editing commands will work as expected
(Ex. dd to delete a file, yy to copy, etc.).

Relevant commands:
- :Oil              (Open Oil in the current file's directory)
- <C-n>             (Open Oil in the current file's directory)
- <leader>b         (Open Oil in the current file's directory)
- <leader>B         (Open Oil in the current working directory)

-----------------------------------------------------------------------------]]

vim.pack.add {
  {
    src = "https://github.com/stevearc/oil.nvim",
    version = "v2.15.0"
  }
}

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

if (vim.fn.argc() == 0
    or vim.fn.argc() == 1
    and vim.fn.isdirectory(
      vim.fn.expand(vim.fn.argv(0) --[[@as string]])
    ) == 1)
  and #vim.api.nvim_list_bufs() == 1
  and vim.api.nvim_buf_line_count(0) == 0
  and vim.api.nvim_get_option_value("buftype", { buf = 0 }) == ""
  and vim.api.nvim_get_option_value("filetype", { buf = 0 }) == ""
then
  oil.open()
end

vim.keymap.set("n", "<leader>b", function() vim.cmd "Oil" end,
  { desc = "Open Oil" })
vim.keymap.set("n", "<C-n>", function() vim.cmd "Oil" end,
  { desc = "Open Oil" })
vim.keymap.set("n", "<leader>B",
  function() vim.cmd("Oil " .. vim.fn.getcwd()) end,
  { desc = "Open Oil in current directory" })
