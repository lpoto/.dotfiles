--=============================================================================
--                                                                       SNACKS
--[[===========================================================================

Configures a collection of smaller plugins (snacks), such
as a fuzzy finder and large file handling

NOTE: Configures a few keymaps for opening different pickers
for finding files, buffers, LSP definitions, diagnostics, etc.

-----------------------------------------------------------------------------]]

vim.pack.add {
  {
    src = "https://github.com/folke/snacks.nvim",
    version = "v2.31.0"
  }
}

require "snacks".setup {
  lazygit = { enabled = false },
  notifier = { enabled = false },
  terminal = { enabled = false },
  input = { enabled = false },
  toggle = { enabled = false },
  bigfile = {
    enabled = true,
    notify = true,
    size = 2 * 1024 * 1024,
    line_length = 100000,
    setup = function(ctx)
      vim.bo[ctx.buf].syntax = "OFF"
    end,
  },
  image = {
    enabled = true,
  },
  zen = {
    enabled = false,
  },
  picker = {
    enabled = true,
    ui_select = true,
    main = {
      file = false,
    },
    icons = {
      files = {
        enabled = false,
      },
    },
    win = {
      input = {
        keys = {
          ["<CR>"] = { "confirm", mode = { "n", "i" } },
          ["<Down>"] = { "list_down", mode = { "n", "i" } },
          ["<Up>"] = { "list_up", mode = { "n", "i" } },
          ["<Esc>"] = { "close", mode = { "n", "i" } },
          ["<c-p>"] = { "select_and_prev", mode = { "n", "i" } },
          ["<c-n>"] = { "select_and_next", mode = { "n", "i" } },
          ["<TAB>"] = { "list_down", mode = { "n", "i" } },
          ["<S-TAB>"] = { "list_up", mode = { "n", "i" } },
        },
      },
      list = {
        keys = {
          ["<CR>"] = "confirm",
          ["<Down>"] = "list_down",
          ["<Esc>"] = "close",
          ["<c-p>"] = { "select_and_prev", mode = { "n", "x" } },
          ["<c-n>"] = { "select_and_next", mode = { "n", "x" } },
          ["<Up>"] = "list_up",
          ["<TAB>"] = "list_down",
          ["<S-TAB>"] = "list_up",
        },
      },
    },
  },
}

local function picker(name, config)
  return function() require "snacks.picker"[name](config) end
end

vim.keymap.set("n", "<leader><space>", picker "smart")
vim.keymap.set("n", "<leader>n", picker "files")
vim.keymap.set("n", "<leader>l", picker "grep")
vim.keymap.set("n", "<leader>L", picker "grep_word")
vim.keymap.set("n", "<leader><cr>", picker "result")
vim.keymap.set("n", "<leader>m", picker "marks")
vim.keymap.set("n", "<leader>h", picker "help")
vim.keymap.set("n", "<leader>q", picker "qflist")
vim.keymap.set("n", "B", picker "buffers")
vim.keymap.set("n", "gd", picker "lsp_definitions")
vim.keymap.set("n", "gi", picker "lsp_implementations")
vim.keymap.set("n", "gr", picker "lsp_references")
vim.keymap.set("n", "gt", picker "lsp_type_definitions")
vim.keymap.set("n", "<leader>E", picker "diagnostics")
vim.keymap.set("n", "<leader>e", function()
  if not vim.diagnostic.open_float() then
    picker "diagnostics_buffer" ()
  end
end)
