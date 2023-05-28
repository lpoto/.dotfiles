--=============================================================================
-------------------------------------------------------------------------------
--                                                                 AUTOCOMMANDS
--[[===========================================================================

-----------------------------------------------------------------------------]]
---------------- Set relative number and cursorline only for the active window,
------------------------------------- and disable them when leaving the window.
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
--------------------------------------------------------- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    Util.require("vim.highlight", function(hl)
      hl.on_yank {
        higroup = "IncSearch",
        timeout = 40,
      }
    end)
  end,
})

-------------------------------------------------------------------------------
--- This is a temporary hack to fix the issue with auto entering
--- insert mode

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end
    vim.defer_fn(function()
      vim.api.nvim_exec("stopinsert", false)
    end, 20)
  end,
})
