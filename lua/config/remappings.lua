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
  "",
  "<expr><Tab>",
  "pumvisible() ? '\\<C-n>' : '\\<TAB>'",
  {
    noremap = true,
    silent = true,
  }
)
vim.api.nvim_set_keymap(
  "",
  "<expr><S-Tab>",
  "pumvisible() ? '\\<C-p>' : '\\<S-TAB>'",
  {
    noremap = true,
    silent = true,
  }
)
vim.api.nvim_set_keymap(
  "",
  "<expr><CR>",
  "pumvisible() ? '\\<C-y>' : '\\<CR>'",
  {
    noremap = true,
    silent = true,
  }
)

--------------------------------------------------------------- WINDOW MANAGING
-- increase the size of a window with +, decrease with -
-- create new vertical split with "<leader> + v"
-- resize all windows to same width with "<leader> + w"

vim.api.nvim_set_keymap("n", "+", "<cmd>vertical resize +5<CR>", {})
vim.api.nvim_set_keymap("n", "-", "<cmd>vertical resize -5<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>v", "<cmd>vertical new<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>w", "<C-W>=", {})

------------------------------------------------------------------- VISUAL MODE
-- Ctrl + c' - yanked text to clipboard

vim.api.nvim_set_keymap("n", "<C-c>", '<cmd>let @+=@"<CR>', {})

----------------------------------------------------------------------- JUMPING
-- center cursor when jumping, jump forward with tab, backward with shift-tab
-- count j and k commands with a number larger than 5 as jumps
-- Navigate quickfix with <leader>l and <leader>h

vim.api.nvim_set_keymap("n", "n", "nzzzv", {})
vim.api.nvim_set_keymap("n", "N", "Nzzzv", {})
vim.api.nvim_set_keymap("n", "J", "mzJ'z", {})
vim.api.nvim_set_keymap("n", "<leader>l", "<cmd>cnext<CR>zzzv", {})
vim.api.nvim_set_keymap("n", "<leader>h", "<cmd>cprev<CR>zzzv", {})
vim.api.nvim_set_keymap("n", "<S-TAB>", "<C-O>zzzv", {})
vim.api.nvim_set_keymap(
  "n",
  "<expr> k",
  '(v:count > 5 ? "m\'" . v:count : "") . \'k\'',
  {}
)
vim.api.nvim_set_keymap(
  "n",
  "<expr> j",
  '(v:count > 5 ? "m\'" . v:count : "") . \'j\'',
  {}
)

----------------------------------------------------------- UNDO BREAK POINTS
-- start a new undo chain with punctuations

vim.api.nvim_set_keymap("i", ",", ",<c-g>u", {})
vim.api.nvim_set_keymap("i", ".", ".<c-g>u", {})
vim.api.nvim_set_keymap("i", "!", "!<c-g>u", {})
vim.api.nvim_set_keymap("i", "?", "?<c-g>u", {})

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

vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-N>", {})

-------------------------------------------------------------- OPEN NVIM CONFIG

vim.api.nvim_create_user_command("Config", function()
  local ok, e = pcall(vim.api.nvim_exec, "find $MYVIMRC", false)
  if ok == false then
    vim.notify(e, vim.log.levels.ERROR)
  else
    vim.fn.chdir(vim.fn.stdpath "config")
  end
end, {})
