--=============================================================================
-------------------------------------------------------------------------------
--                                                               DASHBOARD-NVIM
--=============================================================================
-- https://github.com/glepnir/dashboard-nvim
-------------------------------------------------------------------------------

return {
  "glepnir/dashboard-nvim",
  init = function()
    -- NOTE: use this init function
    -- to load the plugin once the LazyVimStarted
    -- event is triggered, so the lazy stats are available
    -- when configuring the plugin
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      once = true,
      callback = function()
        local db = require "dashboard"

        db.center_pad = 2
        db.custom_center = {
          {
            icon = "  ",
            desc = " Find File                              ",
            action = "Telescope find_files find_command=rg,--hidden,--files",
            shortcut = "SPACE n",
          },
          {
            icon = " ",
            desc = " File Browser                            ",
            action = "Telescope file_browser",
            shortcut = "CTRL N",
          },
          {
            icon = " 🔍",
            desc = " Find Word                              ",
            action = "Telescope live_grep",
            shortcut = "SPACE g",
          },
          {
            icon = "📦",
            desc = " Package Manager                         ",
            action = "Mason",
            shortcut = ":Mason",
          },
          {
            icon = " 🔔",
            desc = " Notifications History                  ",
            action = "lua require('telescope').extensions.notify.notify()",
            shortcut = "SPACE i",
          },
        }

        -- NOTE: add git section only when in a git repo
        local git_dir = vim.fn.finddir(".git", vim.fn.getcwd() .. ";")

        if git_dir ~= "" then
          table.insert(db.custom_center, {
            icon = " ",
            desc = " Git User Interface                        ",
            action = "Git",
            shortcut = ":Git",
          })
        end

        table.insert(db.custom_center, {
          icon = " ",
          desc = " Neovim Config                                ",
          action = "lua require('util.open_nvim_config')",
        })

        db.footer_pad = 2
        db.custom_footer = function()
          local stats = require("lazy").stats()
          return {
            desc = "Loaded " .. stats.count .. " plugins",
          }
        end

        db.header_pad = 5
        db.custom_header = function()
          local stats = require("lazy").stats()
          return {
            " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
            " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
            " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
            " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
            " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
            " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
            require("util.version").get(),
            "",
            "🎉 Loaded in "
              .. (math.floor(stats.startuptime * 100 + 0.5) / 100)
              .. "ms",
          }
        end

        -- Open dashboard only when no file is provided
        if
          vim.fn.argc() == 0
          and vim.fn.line2byte "$" == -1
          and not db.disable_at_vimenter
        then
          db:instance(true)
        end
      end,
    })
  end,
}
