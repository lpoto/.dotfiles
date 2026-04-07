--=============================================================================
--                                                                       SNACKS
--[[===========================================================================
--
-- Configures a collection of smaller plugins (snacks), such
-- as a zen mode, big file handling, and a fuzzy finder.
--
-- NOTE: Configures a few keymaps for opening different pickers
-- for finding files, buffers, LSP definitions, diagnostics, etc.
--
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
  },
  image = {
    enabled = false,
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
