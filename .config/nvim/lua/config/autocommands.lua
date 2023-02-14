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

local id
id = vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.schedule(function()
      local buf = vim.api.nvim_get_current_buf()
      local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
      if buftype:len() == 0 then
        vim.api.nvim_del_autocmd(id)
        vim.api.nvim_exec_autocmds("User", {
          pattern = "RealInsertEnter",
        })
      end
    end)
  end,
})

local id2
id2 = vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.schedule(function()
      local buf = vim.api.nvim_get_current_buf()
      local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
      if buftype:len() == 0 then
        pcall(vim.api.nvim_del_autocmd, id2)
        vim.api.nvim_exec_autocmds("User", {
          pattern = "RealBufEnter",
        })
      end
    end)
  end,
})
