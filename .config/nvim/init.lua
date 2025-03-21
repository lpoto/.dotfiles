--=============================================================================
--                                                                    NVIM-INIT
--=============================================================================
if
  not pcall(function()
    assert(vim.version().minor == 10)
    assert(vim.version().major == 0)
  end)
then
  print "This configuration requires NVIM v0.10.x"
  return
end

vim.cmd.colorscheme "default" -- load colorscheme from ./colors/default.lua

vim.hl = vim.hl or vim.highlight

vim.g.mapleader = " " -- set <leader> key to <Space>
vim.g.maplocalleader = ";" -- set <localleader> key to ';'

vim.opt.splitbelow = true -- open new window below in normal split
vim.opt.splitright = true --open new window on the right in vertical split

vim.opt.swapfile = false -- load buffers without creating swap files
vim.opt.backup = false -- do not automatically save
vim.opt.undofile = true -- allow undo after reoppening the file
vim.opt.undodir = vim.fn.stdpath "state" .. "/undo"

vim.opt.tabstop = 4 -- set the width of a tab to 4
vim.opt.softtabstop = 4 -- set the number of spaces that a tab counts for
vim.opt.shiftwidth = 4 -- number of spaces used for each step of indent
vim.opt.smartindent = true -- smart indent the next line
vim.opt.expandtab = true -- use spaces in tabs
vim.opt.autoindent = true -- auto indent a new line

vim.opt.shortmess:append "c" -- do not give ins-completion-menu messages
vim.opt.smartcase = true -- override ignorecase option
vim.opt.hlsearch = false -- don't highlight search results
vim.opt.incsearch = true -- show results while typing search command

vim.opt.path = ".,,**" -- search down into subfolders
vim.opt.wildmenu = true -- display matching files with tab completion
vim.opt.jumpoptions = "stack" -- make jumplist behave like stack

vim.opt.cursorline = true -- highlight current line
vim.opt.cursorcolumn = false -- do not highlight current column
vim.opt.guicursor = "a:block,a:blinkon0,i-ci:ver25"

vim.opt.showmode = true -- show current mode in command line
vim.opt.cmdheight = 1 -- set command line height to 1
vim.opt.number = true -- show line numbers
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.signcolumn = "number" -- merge signcolumn with number column
vim.opt.errorbells = false -- disable error sounds
vim.opt.updatetime = 50 -- shorten updatetime from 4s to 50ms
vim.opt.timeoutlen = 300 -- shorten timeout for key combinations
vim.opt.exrc = false -- do not source local .nvim.lua files
vim.opt.wrap = false -- do not wrap lines
vim.opt.scrolloff = 8 -- keep 8 lines above and below cursor
vim.opt.title = false -- do not change the terminal title
vim.opt.list = true -- show whitespace characters
vim.opt.listchars =
  { tab = "┊ ", multispace = "· ", leadmultispace = "┊ " }
vim.opt.exrc = true -- Automatically execute .nvim.lua, .nvimrc, and .exrc
