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

--------------------------------------------------------------- SCROLLING POPUP
-- down with tab, up with shift-tab, select with enter

vim.api.nvim_set_keymap(
  "i",
  "<expr><Tab>",
  "pumvisible() ? '\\<C-n>' : '\\<TAB>'",
  {
    noremap = true,
  }
)
vim.api.nvim_set_keymap(
  "i",
  "<expr><S-Tab>",
  "pumvisible() ? '\\<C-p>' : '\\<S-TAB>'",
  {
    noremap = true,
  }
)
vim.api.nvim_set_keymap(
  "i",
  "<expr><CR>",
  "pumvisible() ? '\\<C-y>' : '\\<CR>'",
  {
    noremap = true,
  }
)

--------------------------------------------------------------- WINDOW MANAGING
-- increase the size of a window with +, decrease with -
-- create new vertical split with "<leader> + v"
-- resize all windows to same width with "<leader> + w"

vim.api.nvim_set_keymap("n", "+", "<cmd>vertical resize +5<CR>", {
  noremap = true,
})
vim.api.nvim_set_keymap("n", "-", "<cmd>vertical resize -5<CR>", {
  noremap = true,
})
vim.api.nvim_set_keymap("n", "<leader>v", "<cmd>vertical new<CR>", {
  noremap = true,
})
vim.api.nvim_set_keymap("n", "<leader>w", "<C-W>=", {
  noremap = true,
})

------------------------------------------------------------------- VISUAL MODE
-- Ctrl + c' - yanked text to clipboard

vim.api.nvim_set_keymap(
  "n",
  "<C-c>",
  '<cmd>let @+=@"<CR>',
  { noremap = true }
)

----------------------------------------------------------------------- JUMPING
-- center cursor when jumping, jump forward with tab, backward with shift-tab
-- count j and k commands with a number larger than 5 as jumps

vim.api.nvim_set_keymap("n", "n", "nzzzv", {
  noremap = true,
})
vim.api.nvim_set_keymap("n", "N", "Nzzzv", {
  noremap = true,
})
vim.api.nvim_set_keymap("n", "J", "mzJ'z", {
  noremap = true,
})
vim.api.nvim_set_keymap("n", "<leader>l", "<cmd>cnext<CR>zzzv", {
  noremap = true,
})
vim.api.nvim_set_keymap("n", "<leader>j", "<cmd>cprev<CR>zzzv", {
  noremap = true,
})
vim.api.nvim_set_keymap("n", "<S-TAB>", "<C-O>zzzv", {
  noremap = true,
})
vim.api.nvim_set_keymap(
  "n",
  "<expr> k",
  '(v:count > 5 ? "m\'" . v:count : "") . \'k\'',
  {
    noremap = true,
  }
)
vim.api.nvim_set_keymap(
  "n",
  "<expr> j",
  '(v:count > 5 ? "m\'" . v:count : "") . \'j\'',
  {
    noremap = true,
  }
)

----------------------------------------------------------- UNDO BREAK POINTS
-- start a new undo chain with punctuations

vim.api.nvim_set_keymap("i", ",", ",<c-g>u", { noremap = true })
vim.api.nvim_set_keymap("i", ".", ".<c-g>u", { noremap = true })
vim.api.nvim_set_keymap("i", "!", "!<c-g>u", { noremap = true })
vim.api.nvim_set_keymap("i", "?", "?<c-g>u", { noremap = true })

------------------------------------------------------------------- MOVING TEXT
-- switch lines in normal mode with leader-j or leader-k
-- switch lines in insert mode with ctrl-j or ctrl-k
-- switch selected text in visual mode with J or K

vim.api.nvim_set_keymap("v", "K", "<cmd>m '>+1<CR>gv=gv", { noremap = true })
vim.api.nvim_set_keymap("v", "J", "<cmd>m '<-2<CR>gv=gv", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-k>", "<esc><cmd>m .-2<CR>==", {
  noremap = true,
})
vim.api.nvim_set_keymap("i", "<C-J>", "<esc><cmd>m .+1<CR>==", {
  noremap = true,
})
vim.api.nvim_set_keymap(
  "n",
  "<leader>k",
  "<cmd>m .-2<CR>==",
  { noremap = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>j",
  "<cmd>m .+1<CR>==",
  { noremap = true }
)

----------------------------------------------------------------------- WRITING

vim.api.nvim_create_user_command(
  "W",
  "w",
  { nargs = "*", bang = true, complete = "file" }
)

vim.api.nvim_create_user_command("Q", "q", {
  bang = true,
})
vim.api.nvim_create_user_command("Qw", "qw", {
  nargs = "*",
  bang = true,
  complete = "file",
})
vim.api.nvim_create_user_command("QW", "qw", {
  nargs = "*",
  bang = true,
  complete = "file",
})
vim.api.nvim_create_user_command("Wq", "wq", {
  nargs = "*",
  bang = true,
  complete = "file",
})
vim.api.nvim_create_user_command("WQ", "wq", {
  nargs = "*",
  bang = true,
  complete = "file",
})
