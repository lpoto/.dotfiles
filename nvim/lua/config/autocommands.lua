--=============================================================================
-------------------------------------------------------------------------------
--                                                                 AUTOCOMMANDS
--[[===========================================================================

-----------------------------------------------------------------------------]]
---------------- Set relative number and cursorline only for the active window,
------------------------------------- and disable them when leaving the window.
local relativenumber_augroup =
  vim.api.nvim_create_augroup("RelativeNumberAugroup", { clear = true })

vim.api.nvim_create_autocmd(
  { "VimEnter", "WinEnter", "BufWinEnter", "TermOpen" },
  {
    group = relativenumber_augroup,
    callback = function()
      if vim.wo.number then
        if vim.bo.buftype ~= "" then
          vim.wo.number = false
          vim.wo.relativenumber = false
          vim.wo.cursorline = false
          return
        end
        vim.wo.number = true
        vim.wo.relativenumber = true
        vim.wo.cursorline = true
      end
    end,
  }
)
vim.api.nvim_create_autocmd({ "WinLeave" }, {
  group = relativenumber_augroup,
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
      vim.wo.cursorline = false
    end
  end,
})
--------------------------------------------------------- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
  callback = function()
    Util.require(
      "vim.highlight",
      function(hl)
        hl.on_yank({
          higroup = "IncSearch",
          timeout = 35,
        })
      end
    )
  end,
})

-------------------------------------------------------------------------------
--- This is a temporary hack to fix the issue with auto entering
--- insert mode

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("StopAutoInsert", { clear = true }),
  callback = function()
    if vim.bo.buftype ~= "" then return end
    vim.defer_fn(function() vim.api.nvim_exec("stopinsert", false) end, 20)
  end,
})
