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
        require "dashboard"
      end,
    })
  end,
  config = function()
    local db = require "dashboard"

    db.center_pad = 2
    db.custom_center = {
      {
        icon = "⟳ ",
        icon_hl = { fg = "#dbb671" },
        desc = " Sessions                               ",
        action = "lua require('config.sessions').list_sessions()",
        shortcut = ":Sessions",
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
        desc = " Notifications History                    ",
        action = "Noice",
        shortcut = ":Noice",
      },
      {
        --icon = " ",
        icon = "⚙ ",
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
        desc = "Loaded " .. stats.count .. " plugins in " .. (math.floor(
          stats.startuptime * 100 + 0.5
        ) / 100) .. "ms",
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

    if vim.fn.argc() > 0 or vim.fn.line2byte "$" ~= -1 then
      return
    end
    pcall(function()
      db:instance(true)
    end)
  end,
}
