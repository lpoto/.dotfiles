--=============================================================================
-------------------------------------------------------------------------------
--                                                                 AUTOCOMMANDS
--=============================================================================

---------------- Set relative number and cursorline only for the active window,
------------------------------------- and disable them when leaving the window.
local relativenumber_augroup =
  vim.api.nvim_create_augroup('RelativeNumberAugroup', { clear = true })

vim.api.nvim_create_autocmd(
  { 'VimEnter', 'WinEnter', 'BufWinEnter', 'TermOpen' },
  {
    group = relativenumber_augroup,
    callback = function()
      if vim.wo.number then
        if vim.bo.buftype ~= '' then
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
vim.api.nvim_create_autocmd({ 'WinLeave' }, {
  group = relativenumber_augroup,
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
      vim.wo.cursorline = false
    end
  end,
})
-------------- Set showmode true in empty buftypes and false in other buftypes.
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('ShowMode', { clear = true }),
  callback = function()
    if vim.bo.buftype ~= '' then
      vim.opt.showmode = false
    else
      vim.opt.showmode = true
    end
  end,
})
--------------------------------------------------------- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('HighlightYank', { clear = true }),
  callback = function()
    local ok, hl = pcall(require, 'vim.highlight')
    if ok then
      hl.on_yank {
        higroup = 'IncSearch',
        timeout = 35,
      }
    end
  end,
})

------------------------------------------------------------------------- Shada
-- Store different shada files based on current working directory

local function shada_autocmd(write, read)
  if write then
    pcall(vim.api.nvim_exec2, 'wshada!', {})
  end
  local tail = ((vim.fn.expand '%:p:h') .. '.shada'):gsub('/', '%%')
  local file = vim.fn.stdpath 'data' .. '/shada/' .. tail
  vim.opt.shada = {
    '!',
    "'100",
    '<50',
    's10',
    'h',
    'n' .. file
  }
  if read then
    pcall(vim.api.nvim_exec2, 'rshada!', {})
  end
end
vim.api.nvim_create_autocmd('DirChanged', {
  group = vim.api.nvim_create_augroup('ShadaGroup', { clear = true }),
  callback = function()
    vim.schedule(function()
      shada_autocmd(true, true)
    end)
  end,
})
shada_autocmd(false, false)
