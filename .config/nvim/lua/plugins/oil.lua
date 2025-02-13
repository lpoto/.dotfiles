--=============================================================================
--                                         https://github.com/stevearc/oil.nvim
--[[===========================================================================

Keymaps:
 - "<leader>b"   - file browser relative to current file
 - "<leader>B"   - file browser relative to current working directory

 - "<C-q>"       - (in oil buffer) open quickfix list with all files in oil
                   buffer

-----------------------------------------------------------------------------]]

return {
  "stevearc/oil.nvim",
  tag = "v2.14.0",
  lazy = false,
  keys = {
    { "<leader>b", function() vim.cmd "Oil" end },
    { "<leader>B", function() vim.cmd("Oil " .. vim.fn.getcwd()) end },
    { "<C-n>", function() vim.cmd "Oil" end },
  },
  opts = {
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
  },
}
