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
            icon = " 🗃",
            icon_hl = { fg = "#dbb671" },
            desc = " Recent Files                           ",
            action = "Telescope oldfiles",
            shortcut = "SPACE m",
          },
          {
            icon = "  ",
            icon_hl = { fg = "#dbb671" },
            desc = " Find Files                             ",
            action = "Telescope find_files",
            shortcut = "SPACE n",
          },
          {
            icon = " ",
            icon_hl = { fg = "#dbb671" },
            desc = " File Browser                            ",
            action = "Telescope file_browser",
            shortcut = "CTRL n",
          },
          {
            icon = "⚙ ",
            icon_hl = { fg = "#dbb671" },
            desc = " Neovim Config Files                    ",
            action = "lua require('plugins.telescope').neovim_config_files()",
            shortcut = "SPACE c",
          },
          {
            icon = "☌ ",
            icon_hl = { fg = "#dbb671" },
            desc = " Live Grep                              ",
            action = "Telescope live_grep",
            shortcut = "SPACE g",
          },
          {
            icon = "➡ ",
            icon_hl = { fg = "#dbb671" },
            desc = " Plugins                                  ",
            action = "Lazy",
            shortcut = ":Lazy",
          },
          {
            icon = " ",
            icon_hl = { fg = "#dbb671" },
            desc = " Package Manager                         ",
            action = "Mason",
            shortcut = ":Mason",
          },
          {
            icon = "¡ ",
            icon_hl = { fg = "#dbb671" },
            desc = " Notifications History                  ",
            action = "lua require('plugins.notify').history()",
            shortcut = "SPACE i",
          },
        }

        -- NOTE: add git section only when in a git repo
        local git_dir = vim.fn.finddir(".git", vim.fn.getcwd() .. ";")

        if git_dir ~= "" then
          table.insert(db.custom_center, {
            icon = " ",
            icon_hl = { fg = "#dbb671" },
            desc = " Git User Interface                        ",
            action = "Git",
            shortcut = ":Git",
          })
        end

        db.footer_pad = 2
        db.custom_footer = function()
          local stats = require("lazy").stats()
          return {
            desc = "Loaded "
              .. stats.count
              .. " plugins in "
              .. (math.floor(stats.startuptime * 100 + 0.5) / 100)
              .. "ms",
          }
        end

        db.header_pad = 5
        db.custom_header = function()
          return {
            " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
            " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
            " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
            " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
            " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
            " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
            require("util.version").get(),
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
