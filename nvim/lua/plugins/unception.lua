--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-UNCEPTION
--[[___________________________________________________________________________
https://github.com/samjwill/nvim-unception

Open files from neovim's terminal emulator without nesting sessions.

Add some convenient git commands, as now commit files may be opened from the
terminal emulator.

  - <leader>gc - git commit
  - <leader>ga - git commit --amend
  - <leader>gP - git push
  - <leader>gF - git push --force
  - <leader>gp - git pull
  - <leader>gf - git fetch
  - <leader>gB - git branch
------------------------------------------------------------------------------]]
local M = {
  "samjwill/nvim-unception",
  event = "VeryLazy",
}

local git_commands = {}

function M.init()
  vim.g.unception_block_while_host_edits = true
  vim.g.unception_enable_flavor_text = false

  vim.keymap.set("n", "<leader>g", git_commands.default)
  vim.keymap.set("n", "<leader>gc", git_commands.commit)
  vim.keymap.set("n", "<leader>ga", git_commands.commit_amend)
  vim.keymap.set("n", "<leader>gp", git_commands.pull)
  vim.keymap.set("n", "<leader>gP", git_commands.push)
  vim.keymap.set("n", "<leader>gF", git_commands.push_force)
  vim.keymap.set("n", "<leader>gf", git_commands.fetch)
  vim.keymap.set("n", "<leader>gt", git_commands.tag)
  vim.keymap.set("n", "<leader>gB", git_commands.branch)
end

function M.config()
  vim.api.nvim_create_autocmd("User", {
    pattern = "UnceptionEditRequestReceived",
    once = false,
    callback = function()
      vim.schedule(function()
        pcall(function()
          vim.bo.bufhidden = "wipe"
          vim.bo.swapfile = false
          vim.bo.buflisted = false
        end)
      end)
    end,
  })
end

function git_commands.default(suffix)
  suffix = suffix or ""
  Util.shell():fetch_git_data(function()
    Util.require("plugins.unception", function(_)
      Util.shell():run_in_tab_with_prompt("git ", suffix)
    end)
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
    Util.require("plugins.unception", function(_)
      Util.shell():run_in_tab_with_prompt(
        "git ",
        "push " .. remote .. " " .. branch .. " "
      )
    end)
  end)
end

function git_commands.push_force()
  Util.shell():fetch_git_data(function(remote, branch)
    Util.require("plugins.unception", function(_)
      Util.shell():run_in_tab_with_prompt(
        "git ",
        "push " .. remote .. " " .. branch .. " --force "
      )
    end)
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

function git_commands.pull()
  Util.shell():fetch_git_data(function(remote, branch)
    Util.require("plugins.unception", function(_)
      Util.shell():run_in_tab_with_prompt(
        "git ",
        "pull " .. remote .. " " .. branch .. " "
      )
    end)
  end)
end

return M
