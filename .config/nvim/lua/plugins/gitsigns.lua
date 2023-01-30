--=============================================================================
-------------------------------------------------------------------------------
--                                                                     GITSIGNS
--=============================================================================
-- https://github.com/lewis6991/gitsigns.nvim
-- https://github.com/samjswill/nvim-unception
--[[___________________________________________________________________________

Git decorators.
Show the current line's git blame with a 700ms delay.

Keymaps:
   - <leader>gd: Open diff view
   - <leader>gs: Stage current buffer
   - <leader>gh: Stage hunk
   - <leader>gu: Unstage current buffer
   - <leader>gr: Reset current buffer

Add custom git commands:
   - <leader>gc: Git commit
   - <leader>gP: Git push
   - <leader>gp: Git pull
   - <leader>g or (:Git) :  Custom git command

------------------------------------------------------------------------------]]

local M = {
  "lewis6991/gitsigns.nvim",
  event = { "BufNewFile", "BufReadPre" },
  dependencies = {
    "samjwill/nvim-unception",
  },
}

function M.init()
  vim.keymap.set("n", "<leader>g", M.git_command, {})
  vim.api.nvim_create_user_command("Git", function()
    M.git_command()
  end, {})
  vim.keymap.set("n", "<leader>gc", M.git_commit, {})
  vim.keymap.set("n", "<leader>gP", M.git_push, {})
  vim.keymap.set("n", "<leader>gp", M.git_pull, {})

  vim.g.unception_block_while_host_edits = true
  vim.g.unception_enable_flavor_text = false
end

function M.config()
  local gitsigns = require "gitsigns"

  gitsigns.setup {
    signcolumn = false,
    numhl = true,
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 700,
    },
    on_attach = function(bufnr)
      local gs = require "gitsigns"
      local opts = { buffer = bufnr }

      vim.keymap.set("n", "<leader>gd", gs.diffthis, opts)
      vim.keymap.set("n", "<leader>gs", gs.stage_buffer, opts)
      vim.keymap.set("n", "<leader>gh", gs.stage_hunk, opts)
      vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, opts)
      vim.keymap.set("n", "<leader>gr", gs.reset_buffer, opts)
    end,
  }
  vim.api.nvim_create_autocmd("User", {
    pattern = "UnceptionEditRequestReceived",
    callback = function()
      vim.schedule(function()
        if vim.bo.buftype ~= "" or vim.bo.filetype:match "^git" then
          vim.bo.bufhidden = "wipe"
          vim.bo.swapfile = false
        end
      end)
    end,
  })
end

local call_git_command

function M.git_command()
  call_git_command "git "
end

function M.git_push()
  call_git_command("git push ", "origin " .. (vim.g.gitsigns_head or ""))
end

function M.git_pull()
  call_git_command("git pull ", "origin " .. (vim.g.gitsigns_head or ""))
end

function M.git_commit()
  call_git_command("git commit ", "-a")
end

local run_cmd
function call_git_command(cmd, suffix)
  local f = function()
    if not vim.g.gitsigns_head or vim.g.gitsigns_head:len() == 0 then
      vim.notify("No git HEAD found", vim.log.levels.WARN, {
        title = "Git",
      })
      return
    end
    if suffix then
      suffix = vim.fn.input(cmd, suffix)
    else
      suffix = vim.fn.input(cmd)
    end
    if not suffix or suffix:len() == 0 then
      return
    end
    cmd = cmd .. suffix
    run_cmd(cmd)
  end
  if not package.loaded["gisigns"] then
    M.config()
    vim.defer_fn(f, 100)
  else
    f()
  end
end

function run_cmd(cmd)
  if type(cmd) ~= "table" and type(cmd) ~= "string" then
    vim.notify("'cmd' should be a string or a table", vim.log.levels.WARN, {
      title = "Git Terminal",
    })
    return
  end
  local new_tab = true
  if vim.b.terminal_job_id then
    local r = vim.fn.jobwait({ vim.b.terminal_job_id }, 0)
    local _, n = next(r)
    if n == -3 then
      new_tab = false
    end
  end
  vim.schedule(function()
    local ok, e = pcall(function()
      if new_tab then
        vim.api.nvim_exec("tabnew", false)
      else
        vim.api.nvim_buf_set_option(0, "modified", false)
      end
      vim.fn.termopen(cmd, {
        detach = false,
        env = {
          VISUAL = "nvim",
          EDITOR = "nvim",
        },
      })
    end)
    if not ok and type(e) == "string" then
      vim.notify(e, vim.log.levels.WARN, {
        title = "Git Terminal",
      })
    end
  end)
end

return M
