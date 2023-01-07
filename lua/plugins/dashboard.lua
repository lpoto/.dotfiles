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
            icon = "⟳ ",
            icon_hl = { fg = "#dbb671" },
            desc = " Sessions                               ",
            action = "lua require('config.sessions').list_sessions()",
            shortcut = "Space + s",
          },
          {
            icon = " 🗃",
            icon_hl = { fg = "#dbb671" },
            desc = " Old Files                          ",
            action = "Telescope oldfiles",
            shortcut = "Space + t + o",
          },
          {
            icon = "  ",
            icon_hl = { fg = "#dbb671" },
            desc = " Find Files                         ",
            action = "Telescope find_files",
            shortcut = "Space + t + f",
          },
          {
            icon = "⚙ ",
            icon_hl = { fg = "#dbb671" },
            desc = " Neovim Config Files                ",
            action = "lua require('plugins.telescope').neovim_config_files()",
            shortcut = "Space + t + f",
          },
          {
            icon = " ",
            icon_hl = { fg = "#dbb671" },
            desc = " File Browser                       ",
            action = "Telescope file_browser",
            shortcut = "Space + t + e",
          },
          {
            icon = "☌ ",
            icon_hl = { fg = "#dbb671" },
            desc = " Live Grep                          ",
            action = "Telescope live_grep",
            shortcut = "Space + t + g",
          },
          {
            icon = "⚠ ",
            icon_hl = { fg = "#dbb671" },
            desc = " Notifications History                  ",
            action = "lua require('plugins.notify').history()",
            shortcut = "Space + i",
          },
          {
            icon = " ",
            icon_hl = { fg = "#dbb671" },
            desc = " Package Manager                          ",
            action = "Mason",
            shortcut = ":Mason",
          },
          {
            icon = "➡ ",
            icon_hl = { fg = "#dbb671" },
            desc = " Plugins                                   ",
            action = "Lazy",
            shortcut = ":Lazy",
          },
        }

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
          -- NOTE: allow navigating the dashboard with Tab and Shift+Tab
          if vim.api.nvim_buf_get_option(0, "filetype") == "dashboard" then
            local buffer = vim.api.nvim_get_current_buf()
            vim.keymap.set("n", "<Tab>", function()
              vim.api.nvim_exec("normal! j", true)
            end, { buffer = buffer })
            vim.keymap.set("n", "<S-Tab>", function()
              vim.api.nvim_exec("normal! k", true)
            end, { buffer = buffer })
          end
        end
      end,
    })
  end,
}
