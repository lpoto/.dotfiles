--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-UNCEPTION
--[[___________________________________________________________________________
https://github.com/voldikss/vim-floaterm

Toggle terminal with:
- <leader>t

Add some convenient git commands, as now commit files may be opened in the
same sessino through floaterm.

  - <leader>gc - git commit
  - <leader>ga - git commit --amend
  - <leader>gP - git push
  - <leader>gF - git push --force
  - <leader>gp - git pull
  - <leader>gf - git fetch
  - <leader>gB - git branch
  - <leader>gr - git reset current file
------------------------------------------------------------------------------]]
local M = {
  "voldikss/vim-floaterm",
  cmd = { "FloatermNew", "FloatermToggle", "FloatermKill" },
}

local git_commands = {}

function M.init()
  vim.g.floaterm_autoinsert = false
  vim.g.floaterm_titleposition = "center"
  vim.g.floaterm_giteditor = true
  vim.g.floaterm_position = "center"
  vim.g.floaterm_height = 0.95
  vim.g.floaterm_width = 170
  vim.g.floaterm_wintype = "float"
  vim.g.floaterm_opener = "tabedit"
  vim.g.floaterm_autoclose = 1
  vim.g.floaterm_autohide = 2

  vim.keymap.set("n", "<leader>g", git_commands.default)
  vim.keymap.set("n", "<leader>gc", git_commands.commit)
  vim.keymap.set("n", "<leader>ga", git_commands.commit_amend)
  vim.keymap.set("n", "<leader>gp", git_commands.pull)
  vim.keymap.set("n", "<leader>gP", git_commands.push)
  vim.keymap.set("n", "<leader>gF", git_commands.push_force)
  vim.keymap.set("n", "<leader>gf", git_commands.fetch)
  vim.keymap.set("n", "<leader>gt", git_commands.tag)
  vim.keymap.set("n", "<leader>gB", git_commands.branch)
  vim.keymap.set("n", "<leader>gr", git_commands.restore)

  vim.keymap.set("n", "<leader>t", function()
    vim.api.nvim_exec("FloatermToggle", false)
  end)
end

function git_commands.default(suffix, ask_for_input)
  if ask_for_input == nil then
    ask_for_input = true
  end
  suffix = suffix or ""
  Util.shell():fetch_git_data(function()
    if ask_for_input then
      suffix = vim.fn.input({
        prompt = "git ",
        default = suffix,
        cancelreturn = "",
      })
      if suffix == "" then
        return
      end
    end
    local cmd = "git " .. suffix
    vim.api.nvim_exec("FloatermKill --name=Git", true)
    local title = (" " .. cmd .. " "):gsub("%s+", "\\ ")
    vim.api.nvim_exec(
      "FloatermNew --name=Git --autoclose=0 --title=" .. title .. " " .. cmd,
      false
    )
  end)
end

function git_commands.commit()
  git_commands.default("commit ")
end

function git_commands.commit_amend()
  git_commands.default("commit --amend ")
end

function git_commands.push()
  Util.shell():fetch_git_data(function(remote, branch)
    git_commands.default("push " .. remote .. " " .. branch .. " ")
  end)
end

function git_commands.push_force()
  Util.shell():fetch_git_data(function(remote, branch)
    git_commands.default("push " .. remote .. " " .. branch .. " --force ")
  end)
end

function git_commands.fetch()
  git_commands.default("fetch ")
end

function git_commands.branch()
  git_commands.default("branch ")
end

function git_commands.tag()
  git_commands.default("tag ")
end

function git_commands.restore()
  git_commands.default("restore " .. vim.fn.expand("%:p") .. " ")
end

function git_commands.pull()
  Util.shell():fetch_git_data(function(remote, branch)
    git_commands.default("pull " .. remote .. " " .. branch .. " ")
  end)
end

return M
