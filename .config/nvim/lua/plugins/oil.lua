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
  tag = "v2.12.2",
  cmd = "Oil",
  keys = {
    { "<leader>b", function() vim.cmd "Oil" end },
    { "<leader>B", function() vim.cmd("Oil " .. vim.fn.getcwd()) end },
    { "<C-n>",     function() vim.cmd "Oil" end },
  },
}
local util = {}

M.opts = {
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  buf_options = {
    buflisted = false,
    bufhidden = "wipe",
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
  },
}

function M.init()
  if util.is_starting_screen() then
    vim.cmd(
      "Oil " .. (vim.fn.argc() == 1 and vim.fn.argv(0) or vim.fn.getcwd())
    )
  end
end

function util.is_starting_screen()
  return (
      vim.fn.argc() == 0
      or vim.fn.argc() == 1
      and vim.fn.isdirectory(vim.fn.expand(vim.fn.argv(0) --[[@as string]]))
      == 1
    )
    and #vim.api.nvim_list_bufs() == 1
    and vim.api.nvim_buf_line_count(0) == 0
    and vim.api.nvim_get_option_value("buftype", { buf = 0 }) == ""
    and vim.api.nvim_get_option_value("filetype", { buf = 0 }) == ""
end

return M
