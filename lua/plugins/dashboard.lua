--=============================================================================
-------------------------------------------------------------------------------
--                                                               DASHBOARD-NVIM
--=============================================================================
-- https://github.com/glepnir/dashboard-nvim
-------------------------------------------------------------------------------

return {
  "glepnir/dashboard-nvim",
  cmd = { "Dashboard" },
  init = function()
    -- NOTE: use this init function
    -- to load the plugin once the LazyVimStarted
    -- event is triggered, so the lazy stats are available
    -- when configuring the plugin
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      once = true,
      callback = function()
        if vim.fn.argc() > 0 or vim.fn.line2byte "$" ~= -1 then
          return
        end
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

    pcall(function()
      if vim.fn.line2byte "$" ~= -1 then
        vim.api.nvim_win_set_buf(nil, nil)
      end
      db:instance(true)
    end)
  end,
}
