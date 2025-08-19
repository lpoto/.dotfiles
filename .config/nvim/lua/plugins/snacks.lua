--=============================================================================
--                                         https://github.com/folke/snacks.nvim
--=============================================================================

local function picker(name, config)
  return function() require "snacks.picker"[name](config) end
end

return {
  "folke/snacks.nvim",
  lazy = false,
  tag = "v2.22.0",
  priority = 1000,
  opts = {
    lazygit = { enabled = true },
    notifier = { enabled = true },
    terminal = { enabled = false },
    input = { enabled = false },
    toggle = { enabled = false },
    bigfile = {
      enabled = true,
      notify = true,
      size = 2 * 1024 * 1024,
      line_length = 100000,
    },
    image = {
      enabled = true,
      force = true,
    },
    picker = {
      enabled = true,
      ui_select = true,
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
  },
  keys = {
    { "<leader><space>", picker "smart" },
    { "<leader>n",       picker "files" },
    { "<leader>l",       picker "grep" },
    { "<leader>L",       picker "grep_word" },
    { "<leader><cr>",    picker "resume" },
    { "<leader>m",       picker "marks" },
    { "<leader>h",       picker "help" },
    { "gd",              picker "lsp_definitions" },
    { "gi",              picker "lsp_implementations" },
    { "gr",              picker "lsp_references" },
    { "gt",              picker "lsp_type_definitions" },
    { "<leader>q",       picker "qflist" },
    {
      "<leader>e",
      function()
        if not vim.diagnostic.open_float() then
          picker "diagnostics_buffer" ()
        end
      end,
    },
    { "<leader>E", picker "diagnostics" },
    { "<leader>g", function() require "snacks".lazygit() end },
    { "<leader>G", function() require "snacks".git.blame_line() end },
  },
}
