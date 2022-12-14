--=============================================================================
-------------------------------------------------------------------------------
--                                                                   REMAPPINGS
--=============================================================================
-- This file contains all the default remappings and custom commands.
-- NOTE: plugins and special configs such as the config for netrw, have
-- remappings defined in their own configs.
-------------------------------------------------------------------------------

---Set the default global remappings and user commands
---(renaming file, scrolling popups, window managing, visual mode, jumping,
---undoing breakpoints, moving text, writing,...)

local mapper = require "util.mapper"

--------------------------------------------------------------- SCROLLING POPUP
-- down with tab, up with shift-tab, select with enter

mapper.map("", "<expr><Tab>", "pumvisible() ? '\\<C-n>' : '\\<TAB>'")
mapper.map("", "<expr><S-Tab>", "pumvisible() ? '\\<C-p>' : '\\<S-TAB>'")
mapper.map("", "<expr><CR>", "pumvisible() ? '\\<C-y>' : '\\<CR>'")

--------------------------------------------------------------- WINDOW MANAGING
-- increase the size of a window with +, decrease with -
-- create new vertical split with "<leader> + v"
-- resize all windows to same width with "<leader> + w"

mapper.map("n", "+", "<cmd>vertical resize +5<CR>")
mapper.map("n", "-", "<cmd>vertical resize -5<CR>")
mapper.map("n", "<leader>v", "<cmd>vertical new<CR>")
mapper.map("n", "<leader>w", "<C-W>=")

------------------------------------------------------------------- VISUAL MODE
-- Ctrl + c' - yanked text to clipboard

mapper.map("n", "<C-c>", '<cmd>let @+=@"<CR>')

----------------------------------------------------------------------- JUMPING
-- center cursor when jumping, jump forward with tab, backward with shift-tab
-- count j and k commands with a number larger than 5 as jumps
-- Navigate quickfix with <leader>l and <leader>h

mapper.map("n", "n", "nzzzv")
mapper.map("n", "N", "Nzzzv")
mapper.map("n", "J", "mzJ'z")
mapper.map("n", "<leader>l", "<cmd>cnext<CR>zzzv")
mapper.map("n", "<leader>h", "<cmd>cprev<CR>zzzv")
mapper.map("n", "<S-TAB>", "<C-O>zzzv")
mapper.map("n", "<expr> k", '(v:count > 5 ? "m\'" . v:count : "") . \'k\'')
mapper.map("n", "<expr> j", '(v:count > 5 ? "m\'" . v:count : "") . \'j\'')

----------------------------------------------------------- UNDO BREAK POINTS
-- start a new undo chain with punctuations

mapper.map("i", ",", ",<c-g>u")
mapper.map("i", ".", ".<c-g>u")
mapper.map("i", "!", "!<c-g>u")
mapper.map("i", "?", "?<c-g>u")

----------------------------------------------------------------------- WRITING

mapper.command("W", "w", { nargs = "*", bang = true, complete = "file" })

mapper.command("Q", "q", {
  bang = true,
})
mapper.command("Qw", "qw", {
  nargs = "*",
  bang = true,
  complete = "file",
})
mapper.command("QW", "qw", {
  nargs = "*",
  bang = true,
  complete = "file",
})
mapper.command("Wq", "wq", {
  nargs = "*",
  bang = true,
  complete = "file",
})
mapper.command("WQ", "wq", {
  nargs = "*",
  bang = true,
  complete = "file",
})

---------------------------------------------------------------------- TERMINAL
-- return to normal mode with <Esc>

mapper.map("t", "<Esc>", "<C-\\><C-N>")
