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
        local stats = require("lazy").stats()

        db.custom_center = {
          {
            icon = "   ",
            desc = "Find  File                              ",
            action = "Telescope find_files find_command=rg,--hidden,--files",
            shortcut = "SPACE n",
          },
          {
            icon = "   ",
            desc = "File Browser                            ",
            action = "Telescope file_browser",
            shortcut = "CTRL N",
          },
          {
            icon = "   ",
            desc = "Find  word                              ",
            action = "Telescope live_grep",
            shortcut = "SPACE g",
          },
          {
            icon = "  ",
            desc = "Package manager                         ",
            action = "Mason",
            shortcut = ":Mason",
          },
        }

        -- NOTE: add git section only when in a git repo
        local git_dir = vim.fn.finddir(".git", vim.fn.getcwd() .. ";")

        if git_dir ~= "" then
          table.insert(db.custom_center, {
            icon = " ",
            desc = "Git user interface                      ",
            action = "Git",
            shortcut = ":Git",
          })
        end

        db.custom_footer = {
          desc = "Loaded " .. stats.count .. " plugins",
        }

        db.custom_header = {
          " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
          " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
          " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
          " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
          " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
          " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
          "🎉 Loaded in "
            .. (math.floor(stats.startuptime * 100 + 0.5) / 100)
            .. "ms",
        }

        db:instance(true)
      end,
    })
  end,
}
