--=============================================================================
-------------------------------------------------------------------------------
--                                                                GITSIGNS.NVIM
--=============================================================================
-- https://github.com/lewis6991/gitsigns.nvim
--_____________________________________________________________________________

--[[
Git decorators.

Added lines's numbers are shown in green,
removed in red and modified in blue.

Show the current line's git blame with a 700ms delay.

Keymaps:
   - <leader>gd: Open diff view
   - <leader>gs: Stage current buffer
   - <leader>gh: Stage hunk
   - <leader>gu: Unstage current buffer
   - <leader>gr: Reset current buffer

   - <leader>gg Git status
      see :h telescope.builtin.git_status
   - <leader>gb: Git branches
      see :h telescope.builtin.git_branches
   - <leader>gl Git log
      see :h telescope.builtin.git_commits
   - <leader>gS: Git stash
          - <CR> to apply the selected stash
   - <leader>gf: Git files
   - <leader>gc: Git commit
   - <leader>gP: Git push
   - <leader>gp: Git pull
   - <leader>g or (:Git) :  Custom git command

--]]

local M = {
  "lewis6991/gitsigns.nvim",
  event = { "BufNewFile", "BufReadPre" },
  dependencies = {
    "samjwill/nvim-unception",
  },
}

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

function M.init()
  vim.keymap.set("n", "<leader>g", M.git_command, {})
  vim.api.nvim_create_user_command("Git", function()
    M.git_command()
  end, {})

  vim.keymap.set("n", "<leader>gl", M.git_commits, {})
  vim.keymap.set("n", "<leader>gb", M.git_branches, {})
  vim.keymap.set("n", "<leader>gg", M.git_status, {})
  vim.keymap.set("n", "<leader>gf", M.git_files, {})
  vim.keymap.set("n", "<leader>gS", M.git_stash, {})
  vim.keymap.set("n", "<leader>gc", M.git_commit, {})
  vim.keymap.set("n", "<leader>gP", M.git_push, {})
  vim.keymap.set("n", "<leader>gp", M.git_pull, {})

  vim.g.unception_block_while_host_edits = true
  vim.g.unception_enable_flavor_text = false
end

M.theme = "ivy"

local wrap_opts

function M.git_commits(opts)
  local telescope = require "telescope.builtin"

  opts = wrap_opts(opts)
  telescope.git_commits(opts)
end

function M.git_branches(opts)
  local telescope = require "telescope.builtin"

  opts = wrap_opts(opts)
  telescope.git_branches(opts)
end

function M.git_files(opts)
  local telescope = require "telescope.builtin"

  opts = wrap_opts(opts)
  telescope.git_files(opts)
end

function M.git_stash(opts)
  local telescope = require "telescope.builtin"

  opts = wrap_opts(opts)
  telescope.git_stash(opts)
end

local attach_git_status_mappings
function M.git_status(opts)
  local telescope = require "telescope.builtin"
  opts = wrap_opts(opts)
  opts.attach_mappings = attach_git_status_mappings
  telescope.git_status(opts)
end

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

function attach_git_status_mappings(_, map)
  local actions = require "telescope.actions"
  actions.select_default:replace(actions.git_staging_toggle)
  map("n", "e", actions.file_edit)
  map("i", "<C-e>", actions.file_edit)
  map("i", "<Tab>", actions.move_selection_next)
  map("i", "<Tab>", actions.move_selection_next)
  map("n", "<Tab>", actions.move_selection_next)
  map("i", "<S-Tab>", actions.move_selection_previous)
  map("n", "<S-Tab>", actions.move_selection_previous)
  map("n", "s", actions.git_staging_toggle)
  map("i", "<C-s>", actions.git_staging_toggle)
  map("n", "<C-s>", actions.git_staging_toggle)
  return true
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

wrap_opts = function(opts)
  opts = vim.tbl_extend(
    "force",
    require("telescope.themes")["get_" .. M.theme](),
    opts or {}
  )
  if not opts.selection_strategy then
    opts.selection_strategy = "row"
  end
  return opts
end

return M
