--=============================================================================
--                                         https://github.com/folke/snacks.nvim
--=============================================================================

local function picker(name, config)
  return function() require "snacks.picker"[name](config) end
end

local M = {
  "folke/snacks.nvim",
  lazy = false,
  tag = "v2.31.0",
  priority = 1000,
  opts = {
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
    },
    image = {
      enabled = true,
      force = true,
    },
    zen = {
      enabled = true,
      center = true,
      toggles = {
        dim = false,
      },
      show = {
        tabline = true,
      },
      on_open = function(_)
        vim.cmd "cabbrev q! let b:quitting_bang = 1 <bar> q!"
        vim.api.nvim_create_autocmd("QuitPre", {
          group = vim.api.nvim_create_augroup("SnacksZenQuit", { clear = true }),
          callback = function()
            local count = 0
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              if vim.api.nvim_win_get_config(win).relative == "" then
                count = count + 1
              end
            end
            vim.b.quitting = count <= 1
          end,
        })
      end,
      on_close = function()
        vim.schedule(function()
          if vim.b.quitting == true then
            vim.b.quitting = false
            if vim.b.quitting_bang == 1 then
              vim.b.quitting_bang = 0
              vim.cmd "q!"
            else
              vim.cmd "q"
            end
          end
        end)
      end,
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
    { "B",               picker "buffers" },
    {
      "<leader>e",
      function()
        if not vim.diagnostic.open_float() then
          picker "diagnostics_buffer" ()
        end
      end,
    },
    { "<leader>E", picker "diagnostics" },
  },
}

function M.init()
  vim.api.nvim_create_autocmd("BufNew", {
    callback = function(opts)
      if vim.bo[opts.buf].buftype ~= "" then return end
      vim.schedule(function()
        if vim.bo[opts.buf].buftype == "quickfix" then
          pcall(function()
            local win = vim.fn.bufwinid(opts.buf)
            vim.api.nvim_buf_delete(opts.buf, { force = true })
            vim.api.nvim_win_close(win, true)
          end)
          picker "qflist" ()
        end
      end)
    end
  })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave", "WinLeave" }, {
    callback = function()
      if vim.api.nvim_win_get_config(0).relative ~= "" then
        return
      end
      vim.schedule(function()
        if vim.api.nvim_win_get_config(0).relative ~= "" then
          return
        end
        local count = 0
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_get_config(win).relative ~= "" then
            return
          end
          count = count + 1
        end
        if count ~= 1 then
          return
        end
        local snacks = require "snacks"
        if type(snacks.zen.win) == "table" and not snacks.zen.win.closed then
          return
        end

        -- TODO: More sophisticated
        -- 1. Determine width dynamically based on line length
        -- 2. Disable this for some filetypes
        local max_width = math.min(120, vim.o.columns)
        local col = math.max(0, math.floor(vim.o.columns - max_width) / 2)
        local width = vim.o.columns - col
        snacks.zen {
          center = false,
          win = {
            col = col,
            width = width
          },
        }
      end)
    end
  })
end

return M
