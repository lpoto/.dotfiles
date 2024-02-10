--=============================================================================
--                                                               PLUGIN-KEYMAPS
--=============================================================================
if vim.g.did_keys or vim.api.nvim_set_var("did_keys", true) then return end

--------------------------------------------------------------- WINDOW MANAGING
-- increase the size of a window with +, decrease with -
-- resize all windows to same width with "<ctrl> + w"

vim.keymap.set("n", "+", "<cmd>vertical resize +10<CR>")
vim.keymap.set("n", "-", "<cmd>vertical resize -10<CR>")

-- Switch window with <leader>w
vim.keymap.set("n", "<leader>w", "<cmd>wincmd w<cr>")

----------------------------------------------------------------------- JUMPING
-- center cursor when jumping, jump forward with tab, backward with shift-tab
-- Navigate quickfix with <leader>k and <leader>j

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "J", "mzJ'z")
vim.keymap.set("n", "<leader>k", "<cmd>cnext<CR>zzzv")
vim.keymap.set("n", "<leader>j", "<cmd>cprev<CR>zzzv")

vim.keymap.set("n", "<TAB>", "<C-I>zzzv")
vim.keymap.set("n", "<S-TAB>", "<C-O>zzzv")

--- Don't modify jumplist when jumping with { and }
vim.keymap.set("n", "{", "<cmd>execute 'keepjumps norm! ' . v:count1 . '{'<CR>")
vim.keymap.set("n", "}", "<cmd>execute 'keepjumps norm! ' . v:count1 . '}'<CR>")

----------------------------------------------------------------- UNDO AND REDO
-- start a new undo chain with punctuations

vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", "!", "!<c-g>u")
vim.keymap.set("i", "?", "?<c-g>u")

-- Redo with <leader>u
vim.keymap.set("n", "<leader>u", "<C-r>")

---------------------------------------------------------------------- TERMINAL
-- return to normal mode with <Esc>
-- Toggle terminal in a new tab with <C-t>

vim.keymap.set("t", "<Esc>", "<C-\\><C-N>")

----------------------------------------------------------------------- YANKING
-- Copy to external clipboard by adding <leader> prefix to yank
--
vim.keymap.set({ "v", "n" }, "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+yg_')
vim.keymap.set("n", "<leader>yy", '"+yy')
--
-- Paste from clipboard by adding <leader> prefix to paste
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P')

for i = 1, 9 do
  vim.keymap.set("n", "<localleader>" .. i, i .. "gt")
end

------------------------------------------------------------------------ PARENS

vim.keymap.set("i", "<CR>", function()
  ---@diagnostic disable-next-line
  local line = vim.fn.getline "."
  local col = vim.fn.col "."
  ---@diagnostic disable-next-line
  local next = line:sub(col, col)
  if vim.tbl_contains({ "}", "]" }, next) then return "<CR><Esc>ko" end
  return "<CR>"
end, { expr = true })

----------- Abrreviate misstyped w, q, wq, wa, qa and wqa commands to lowercase
-- so that there is no annoyance when misspelling them
vim.cmd.cnoreabbrev("W  ", "w")
vim.cmd.cnoreabbrev("Q  ", "q")
vim.cmd.cnoreabbrev("Wq  ", "wq")
vim.cmd.cnoreabbrev("WQ  ", "wq")
vim.cmd.cnoreabbrev("wQ  ", "wq")
vim.cmd.cnoreabbrev("Wa  ", "wa")
vim.cmd.cnoreabbrev("WA  ", "wa")
vim.cmd.cnoreabbrev("wA  ", "wa")
vim.cmd.cnoreabbrev("Qa  ", "qa")
vim.cmd.cnoreabbrev("aA  ", "qa")
vim.cmd.cnoreabbrev("QA  ", "qa")
vim.cmd.cnoreabbrev("wqA  ", "wqa")
vim.cmd.cnoreabbrev("wQa  ", "wqa")
vim.cmd.cnoreabbrev("Wqa  ", "wqa")
vim.cmd.cnoreabbrev("WQa  ", "wqa")
vim.cmd.cnoreabbrev("WqA  ", "wqa")
vim.cmd.cnoreabbrev("WQA  ", "wqa")
