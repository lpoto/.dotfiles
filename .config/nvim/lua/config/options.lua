--=============================================================================
-------------------------------------------------------------------------------
--                                                                      OPTIONS
--=============================================================================
----------------------------------Set the default global options for the editor

vim.g.mapleader = ' '      ---------------------------  map <leader> to <Space>
vim.g.maplocalleader = ';' ----------------------  map <localleader> to     ";"

vim.opt.errorbells = false -- disable error sounds
vim.opt.updatetime = 50    -- shorten updatetime from 4s to 50ms
vim.opt.timeoutlen = 300   -- shorten timeout for key combinations
vim.opt.exrc = false       -- do not source local .nvim.lua files
vim.opt.splitbelow = true  -- open new window below in normal split
vim.opt.splitright = true  --open new window on the right in vertical split

------------------------------------------------------------------- SAVE / UNDO

vim.opt.swapfile = false -- load buffers without creating swap files
vim.opt.backup = false   -- do not automatically save
vim.opt.undofile = true  -- allow undo after reoppening the file
vim.opt.undodir = vim.fn.stdpath 'data' .. '/undo'

--------------------------------------------------------------------- INDENTING

vim.opt.tabstop = 4        -- set the width of a tab to 4
vim.opt.softtabstop = 4    -- set the number of spaces that a tab counts for
vim.opt.shiftwidth = 4     -- number of spaces used for each step of indent
vim.opt.smartindent = true -- smart indent the next line
vim.opt.expandtab = true   -- use spaces in tabs
vim.opt.autoindent = true

----------------------------------------------------------------------- FOLDING

-- Fold visual selection with zf, toggle fold with za ...
vim.opt.foldmethod = 'manual'

------------------------------------------------------------------ AUTOCOMPLETE

vim.opt.shortmess = vim.opt.shortmess + 'c' -- don't give ins-completion-menu
vim.opt.completeopt = 'menu,menuone,noselect'

--------------------------------------------------------------------- SEARCHING

vim.opt.smartcase = true      -- override ignorecase option
vim.opt.hlsearch = false      -- stop highlighting for hlsearch option
vim.opt.incsearch = true
vim.opt.path = '.,,**'        -- search down into subfolders
vim.opt.wildmenu = true       -- display matching files with tab completion

vim.opt.jumpoptions = 'stack' -- make jumplist behave like stack

---------------------------------------------------------------------------- UI

vim.opt.background = 'dark'
vim.opt.number = true
--vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.incsearch = true
vim.opt.title = false
vim.opt.signcolumn = 'number'
vim.opt.showmode = true
vim.opt.cmdheight = 1
vim.opt.guicursor = 'a:blinkon0'
vim.opt.cursorline = true
vim.opt.cursorcolumn = false
--vim.opt.colorcolumn = +1
vim.t_Co = 256
vim.opt.termguicolors = true
vim.cmd 'let &t_8f = "\\<Esc>[38;2;%lu;%lu;%lum"'
vim.cmd 'let &t_8b = "\\<Esc>[48;2;%lu;%lu;%lum"'

vim.opt.listchars:append {
  tab = '│ ',
  multispace = '. ',
  leadmultispace = '│ ',
}
vim.opt.list = true

--=============================================================================
-------------------------------------------------------------------------------
--                                                                 AUTOCOMMANDS
--[[===========================================================================

-----------------------------------------------------------------------------]]
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
