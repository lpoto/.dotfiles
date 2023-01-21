--=============================================================================
-------------------------------------------------------------------------------
--                                                                 VIM-FLOATERM
--=============================================================================
-- https://github.com/voldikss/vim-floaterm
--[[---------------------------------------------------------------------------

Terminal manager for neovim

Keymaps:
  - <C-t> - Toggle terminal
]]

local M = {
  "voldikss/vim-floaterm",
  cmd = { "FloatermNew", "FloatermToggle" },
}

function M.config()
  vim.g.floaterm_width = 0.40
  vim.g.floaterm_height = 0.90
  vim.g.floaterm_giteditor = true
  vim.g.floaterm_opener = "tabe"
  vim.g.floaterm_autoinsert = false
end

function M.init()
  vim.api.nvim_create_augroup("FloatermConfig", { clear = true })
  vim.api.nvim_create_autocmd("Filetype", {
    group = "FloatermConfig",
    pattern = "floaterm",
    callback = function()
      local next = function()
        vim.api.nvim_command "FloatermNext"
      end
      local prev = function()
        vim.api.nvim_command "FloatermPrev"
      end
      local new = function()
        vim.api.nvim_command "FloatermNew"
      end
      local buf = vim.api.nvim_get_current_buf()
      local map = function(modes, map, f)
        vim.keymap.set(modes, map, f, { buffer = buf })
      end
      map({ "n", "i" }, "<C-l>", next)
      map({ "n", "i" }, "<C-k>", next)
      map({ "n", "i" }, "<C-j>", prev)
      map({ "n", "i" }, "<C-h>", prev)
      map("n", "<leader>h", prev)
      map("n", "<leader>j", prev)
      map("n", "<leader>k", next)
      map("n", "<leader>l", next)
      map({ "n", "i" }, "<C-n>", new)
      map("n", "<leader>n", new)
    end,
  })
  vim.keymap.set("n", "<C-t>", function()
    vim.api.nvim_command "FloatermToggle"
  end)
end

return M
