--=============================================================================
--                                                                     GITSIGNS
--[[===========================================================================

Git signs for Neovim. Shows added, changed, and removed lines in the sign
column, and can show inline blame information for the current line.
Also provides some helpful line/chunk git actions.

NOTE: This is not used to cover all git actions,
but mostly to provide some helpful git information in the buffers itself,
while using other tools like lazygit for more complex git actions.

Relevant commands:
- :Gitsigns      (all gitsigns actions)
- <leader>G      (current line actions)

-----------------------------------------------------------------------------]]

vim.pack.add {
  {
    src = "https://github.com/lewis6991/gitsigns.nvim",
    tag = "v2.1.0",
  }
}

vim.schedule(function()
  require "gitsigns".setup {
    signcolumn = false,
    numhl = true,
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 1000,
    },
    update_debounce = 250,
    auto_attach = true,
    attach_to_untracked = true,
    on_attach = function(b)
      -- Create a custom command that shows available gitsigns actions
      vim.keymap.set(
        { "n", "v" },
        "<leader>G",
        function()
          local actions = {
            { value = "blame", name = "Blame" },
          }
          local possible_actions = require "gitsigns".get_actions();
          if type(possible_actions) == "table" then
            for value, action in pairs(possible_actions) do
              local name = value:gsub("_", " ")
              name = name:gsub("^%l", string.upper)
              table.insert(actions,
                { value = value, name = name, action = action })
            end
          end
          table.insert(actions, { value = "lazygit", name = "LazyGit" })
          vim.ui.select(actions,
            {
              prompt = "Git Actions:",
              format_item = function(item)
                return item.name
              end,
            },
            function(choice)
              if not choice then
                return
              end
              if type(choice.action) == "function" then
                choice.action()
                return
              end
              if choice.value == "lazygit" then
                require "snacks".lazygit()
                return
              end
              if choice and choice.value then
                require "gitsigns"[choice.value]()
              end
            end)
        end,
        { buffer = b, desc = "Git blame" })
    end
  }
end)
