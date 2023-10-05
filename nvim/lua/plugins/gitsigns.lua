--=============================================================================
-------------------------------------------------------------------------------
--                                                                GITSIGNS.NVIM
--[[===========================================================================
https://github.com/lewis6991/gitsigns.nvim
https://github.com/willothy/flatten.nvim

Show git blames of current line, allow staging hunks and buffers...
Use flatten to open git commit files etc. in the same neovim session

keymaps:
# gitsigns
    - <leader>gd - Git diff
    - <leader>gs - Git stage buffer
    - <leader>gh - Git stage hunk
    - <leader>gu - Git unstage hunk
    - <leader>gr - Git reset buffer
# flatten
    - <leader>gc - Git commit
    - <leader>ga - Git commit amend
    - <leader>gp - Git pull
    - <leader>gP - Git push
    - <leader>gF - Git push force
    - <leader>gt - Git tag
    - <leader>gB - Git branch

-----------------------------------------------------------------------------]]
local M = {
  "lewis6991/gitsigns.nvim",
  event = { "BufRead", "BufNewFile" },
  opts = {
    signcolumn = false,
    numhl = true,
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 1000,
    },
    update_debounce = 250,
    on_attach = function(buf)
      local gitsigns = package.loaded.gitsigns
      local map = function(m, k, f) vim.keymap.set(m, k, f, { buffer = buf }) end
      map("n", "<leader>gd", gitsigns.diffthis)
      map("n", "<leader>gs", gitsigns.stage_buffer)
      map("n", "<leader>gh", gitsigns.stage_hunk)
      map("n", "<leader>gu", gitsigns.undo_stage_hunk)
      map("n", "<leader>gr", gitsigns.reset_buffer)
      if not vim.g.gitsigns_logged then
        vim.notify(
          "Attached gitsigns",
          vim.log.levels.INFO,
          { title = "Git" }
        )
        vim.g.gitsigns_logged = true
      end
    end,
  },
  dependencies = {
    {
      "willothy/flatten.nvim",
      event = "VeryLazy",
      opts = {
        callbacks = {
          should_block = function() return true end,
          should_nest = function() return false end,
        },
        block_for = {},
        window = {
          diff = "tab_vsplit",
          open = function(files, _, stdin_buf)
            local focus = files[1] or files[#files]
            if stdin_buf then focus = stdin_buf end
            local buf, win = require("abstract.shell.core").open_window(
              " " .. (focus.fname or "") .. " "
            )
            vim.api.nvim_set_current_buf(focus.bufnr)
            buf = focus.bufnr
            return buf, win
          end,
        },
      },
    },
  },
}

local run
function M.init()
  vim.keymap.set("n", "<leader>g", run("<INPUT> git"))
  vim.keymap.set("n", "<leader>gc", run("<INPUT> git commit"))
  vim.keymap.set("n", "<leader>ga", run("<INPUT> git commit --amend"))
  vim.keymap.set(
    "n",
    "<leader>gp",
    run("<INPUT> git pull <GIT_REMOTE> <GIT_BRANCH>")
  )
  vim.keymap.set(
    "n",
    "<leader>gP",
    run("<INPUT> git push <GIT_REMOTE> <GIT_BRANCH>")
  )
  vim.keymap.set(
    "n",
    "<leader>gF",
    run("<INPUT> git push <GIT_REMOTE> <GIT_BRANCH> -f")
  )
  vim.keymap.set("n", "<leader>gf", run("<INPUT> git fetch"))
  vim.keymap.set("n", "<leader>gt", run("<INPUT> git tag"))
  vim.keymap.set("n", "<leader>gB", run("<INPUT> git branch"))
end

function run(cmd)
  return function() return require("abstract.shell").run(cmd) end
end

return M
