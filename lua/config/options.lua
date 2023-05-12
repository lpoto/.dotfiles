--=============================================================================
-------------------------------------------------------------------------------
--                                                                      OPTIONS
--=============================================================================
-- Defines all the general neovim options
-------------------------------------------------------------------------------

vim.g["mapleader"] = " " -------------------------------  map <leader> to space

---Set the default global options for the editor
---(save/undo, indenting, autocomplete, searching, ui)
vim.opt.errorbells = false -- disable error sounds
vim.opt.updatetime = 50 -- shorten updatetime from 4s to 50ms
vim.opt.timeoutlen = 300 -- shorten timeout for key combinations
vim.opt.exrc = false -- do not source local .nvim.lua files
vim.opt.splitbelow = true -- open new window below in normal split
vim.opt.splitright = true --open new window on the right in vertical split

------------------------------------------------------------------- SAVE / UNDO

vim.opt.swapfile = false -- load buffers without creating swap files
vim.opt.backup = false -- do not automatically save
vim.opt.undofile = true -- allow undo after reoppening the file
vim.opt.undodir = require("config.util").path(vim.fn.stdpath "data", ".undo")

--------------------------------------------------------------------- INDENTING

vim.opt.tabstop = 4 -- set the width of a tab to 4
vim.opt.softtabstop = 4 -- set the number of spaces that a tab counts for
vim.opt.shiftwidth = 4 -- number of spaces used for each step of indent
vim.opt.smartindent = true -- smart indent the next line
vim.opt.expandtab = true -- use spaces in tabs

----------------------------------------------------------------------- FOLDING

-- Fold visual selection with zf, toggle fold with za ...
vim.opt.foldmethod = "manual"

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

-------------------------------------------------------------------- STATUSLINE
vim.opt.laststatus = 3
vim.opt.statusline = table.concat({
  " %-5{%v:lua.string.upper(v:lua.vim.fn.mode())%}", -- show mode
  "%f", -- show filename, relative to cwd
  "%-m ", -- show modified flar (or readonly)
  " %{%len(v:lua.vim.diagnostic.get(0)) > 0 ? " -- show diagnostics
    .. "'!' .. len(v:lua.vim.diagnostic.get(0)) : '' %}",
  " %= ",
  " %{get(g:,'gitsigns_head','')} ", -- show git branch
  "%{get(b:,'gitsigns_status','')} ", -- show git diff
  "%15([%l,%c%)]", -- show line and column
  " %3p%% ", -- show percentage through file
}, "")

---------------------------------------------------------------------------- UI

vim.opt.background = "dark"
vim.opt.number = true
--vim.opt.relativenumber = true
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

vim.opt.listchars:append { tab = "│ ", multispace = "│ " }
vim.opt.list = true

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
    require("vim.highlight").on_yank {
      higroup = "IncSearch",
      timeout = 40,
    }
  end,
})
