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

vim.keymap.set("", "<expr><Tab>", "pumvisible() ? '\\<C-n>' : '\\<TAB>'")
vim.keymap.set("", "<expr><S-Tab>", "pumvisible() ? '\\<C-p>' : '\\<S-TAB>'")
vim.keymap.set("", "<expr><CR>", "pumvisible() ? '\\<C-y>' : '\\<CR>'")

--------------------------------------------------------------- WINDOW MANAGING
-- increase the size of a window with +, decrease with -
-- create new vertical split with "<leader> + v"
-- resize all windows to same width with "<leader> + w"

vim.keymap.set("n", "+", "<cmd>vertical resize +5<CR>")
vim.keymap.set("n", "-", "<cmd>vertical resize -5<CR>")
vim.keymap.set("n", "<leader>v", "<cmd>vertical new<CR>")

-- Switch window with <leader>w
vim.keymap.set("n", "<leader>w", "<cmd>wincmd w<cr>")

------------------------------------------------------------------- VISUAL MODE
-- Ctrl + c' - yanked text to clipboard

-- Copy to external clipboard by adding <leader> prefix to yank
--
vim.keymap.set({ "v", "n" }, "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+yg_')
vim.keymap.set("n", "<leader>yy", '"+yy')
--
-- Paste from clipboard by adding <leader> prefix to paste
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P')

----------------------------------------------------------------------- JUMPING
-- center cursor when jumping, jump forward with tab, backward with shift-tab
-- count j and k commands with a number larger than 5 as jumps
-- Navigate quickfix with <leader>l and <leader>h

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "J", "mzJ'z")
vim.keymap.set("n", "<leader>l", "<cmd>cnext<CR>zzzv")
vim.keymap.set("n", "<leader>h", "<cmd>cprev<CR>zzzv")
vim.keymap.set("n", "<S-TAB>", "<C-O>zzzv")
vim.keymap.set(
  "n",
  "<expr> k",
  '(v:count > 5 ? "m\'" . v:count : "") . \'k\''
)
vim.keymap.set(
  "n",
  "<expr> j",
  '(v:count > 5 ? "m\'" . v:count : "") . \'j\''
)

----------------------------------------------------------- UNDO BREAK POINTS
-- start a new undo chain with punctuations

vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", "!", "!<c-g>u")
vim.keymap.set("i", "?", "?<c-g>u")

-- Redo with <leader>r
vim.keymap.set("n", "<leader>r", "<C-r>")

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

---------------------------------------------------------------------- TERMINAL
-- return to normal mode with <Esc>
-- Toggle terminal with <C-t>

vim.keymap.set("t", "<Esc>", "<C-\\><C-N>")

vim.keymap.set("n", "<C-t>", function()
  require "util.toggle_terminal" ()
end)
