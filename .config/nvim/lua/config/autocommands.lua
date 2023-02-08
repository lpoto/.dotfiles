--=============================================================================
-------------------------------------------------------------------------------
--                                                                 AUTOCOMMANDS
--=============================================================================

--------------------------------------------------------- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    require("vim.highlight").on_yank {
      higroup = "IncSearch",
      timeout = 40,
    }
  end,
})

----------------- Set relative number and cursorline only for the active window
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = true
      vim.wo.cursorline = true
    end
  end,
})
vim.api.nvim_create_autocmd({ "WinLeave" }, {
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
      vim.wo.cursorline = false
    end
  end,
})
