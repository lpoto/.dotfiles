--=============================================================================
-------------------------------------------------------------------------------
--                                                                    INIT NVIM
--=============================================================================
-- This file defines all the general neovim options, other general configs
-- are sourced after this file in the plugin/ directory.
-- External plugins are defined in lua/plugins/ but are loaded in the
-- after/ directory. Filetype specific configs are defined in ftplugin/,
-- those are sourced when the filetype of the opened file matches the name
-- of the config file.
-------------------------------------------------------------------------------

vim.g["mapleader"] = " " -- map <leader> to space

---Set the default global options for the editor
---(save/undo, indenting, autocomplete, searching, ui)
vim.opt.errorbells = false -- disable error sounds
vim.opt.updatetime = 50 -- shorten updatetime from 4s to 50ms
vim.opt.timeoutlen = 500 -- shorten timeout for key combinations
vim.opt.exrc = false -- do not source local .nvimrc files
vim.opt.splitbelow = true -- open new window below in normal split
vim.opt.splitright = true --open new window on the right in vertical split

------------------------------------------------------------------- SAVE / UNDO

vim.opt.swapfile = false -- load buffers without creating swap files
vim.opt.backup = false -- do not automatically save
vim.opt.undofile = true -- allow undo after reoppening the file
vim.opt.undodir = vim.fn.stdpath "config" .. "/.undo" -- change undodir path

--------------------------------------------------------------------- INDENTING

vim.opt.tabstop = 4 -- set the width of a tab to 4
vim.opt.softtabstop = 4 -- set the number of spaces that a tab counts for
vim.opt.shiftwidth = 4 -- number of spaces used for each step of indent
vim.opt.smartindent = true -- smart indent the next line
vim.opt.expandtab = true -- use spaces in tabs

------------------------------------------------------------------ AUTOCOMPLETE

vim.opt.shortmess = vim.opt.shortmess + "c" -- don't give ins-completion-menu
vim.opt.completeopt = "menu,menuone,noselect"

--------------------------------------------------------------------- SEARCHING

vim.opt.smartcase = true -- override ignorecase option
vim.opt.hlsearch = false -- stop highlighting for hlsearch option
vim.opt.incsearch = true
vim.opt.path = ".,,**" -- search down into subfolders
vim.opt.wildmenu = true -- display matching files with tab completion

vim.opt.jumpoptions = "stack" -- make jumplist behave like stack

---------------------------------------------------------------------------- UI

vim.opt.background = "dark"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.incsearch = true
vim.opt.title = false
vim.opt.signcolumn = "number"
vim.opt.showmode = false
vim.opt.guicursor = "a:blinkon0"
vim.opt.cursorline = true
vim.opt.cursorcolumn = false
--vim.opt.colorcolumn = +1
vim.t_Co = 256
vim.opt.termguicolors = true
vim.cmd 'let &t_8f = "\\<Esc>[38;2;%lu;%lu;%lum"'
vim.cmd 'let &t_8b = "\\<Esc>[48;2;%lu;%lu;%lum"'

-------------------------------------------------------------------- STATUSLINE
-- disable statusline by default, it may then be enabled by plugins

vim.opt.laststatus = 0
vim.opt.statusline = ""

----------------------------------------------------------------------- PLUGINS
-- Load all the plugins with lazy.nvim

require "config.lazy"

------------------------------------------------------------------- COLORSCHEME
-- set up one of the color schemes configured in lua/plugins/colorschemes/

--vim.cmd[[colorscheme gruvbox]]
--vim.cmd[[colorscheme tokyonight-night]]
--vim.cmd[[colorscheme tokyonight-storm]]
--vim.cmd[[colorscheme tokyonight-day]]
--vim.cmd[[colorscheme tokyonight-moon]]
vim.cmd[[colorscheme onedark]]
