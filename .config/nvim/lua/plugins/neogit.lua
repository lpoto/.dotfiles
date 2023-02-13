--=============================================================================
-------------------------------------------------------------------------------
--                                                                       NEOGIT
--[[___________________________________________________________________________
https://github.com/TimUntersberger/neogit

Commands:
  - Git (or :Neogit)  - Open the git interface
-----------------------------------------------------------------------------]]
--
local M = {
  "TimUntersberger/neogit",
  cmd = { "Git", "Neogit", "DiffviewOpen" },
  dependencies = {
    "sindrets/diffview.nvim",
  },
}

M.config = function()
  --NOTE: create a "Git" command that matches
  --the  "Neogit" command from the plugin
  vim.api.nvim_create_user_command("Git", function(o)
    local neogit = require "neogit"
    neogit.open(require("neogit.lib.util").parse_command_args(o.fargs))
  end, {
    nargs = "*",
    desc = "Open Neogit",
    complete = function(arglead)
      local neogit = require "neogit"
      return neogit.complete(arglead)
    end,
  })

  local neogit = require "neogit"
  neogit.setup {
    disable_commit_confirmation = true,
    integrations = {
      diffview = true,
    },
  }

  local diffview = require "diffview"
  diffview.setup {
    use_icons = false,
    keymaps = {
      view = {
        {
          "n",
          "q",
          function()
            vim.cmd "DiffviewClose!"
          end,
        },
      },
      file_panel = {
        {
          "n",
          "q",
          function()
            vim.cmd "DiffviewClose!"
          end,
        },
        {
          "n",
          "<esc>",
          function()
            vim.cmd "DiffviewClose!"
          end,
        },
      },
    },
  }
end

M.keys = {
  {
    "<leader>gg",
    "<cmd>Neogit<CR>",
    mode = "n",
  },
  {
    "<leader>gl",
    "<cmd>Neogit log<CR>",
    mode = "n",
  },
  {
    "<leader>gc",
    "<cmd>Neogit commit<CR>",
    mode = "n",
  },
  {
    "<leader>gp",
    "<cmd>Neogit pull<CR>",
    mode = "n",
  },
  {
    "<leader>gP",
    "<cmd>Neogit push<CR>",
    mode = "n",
  },
  {
    "<leader>gd",
    "<cmd>DiffviewOpen<CR>",
    mode = "n",
  },
  {
    "<leader>gb",
    "<cmd>Neogit branch<CR>",
    mode = "n",
  },
}

return M
