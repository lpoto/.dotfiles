--=============================================================================
-------------------------------------------------------------------------------
--                                                               DASHBOARD-NVIM
--=============================================================================
-- https://github.com/glepnir/dashboard-nvim
-------------------------------------------------------------------------------

local M = {
  "goolord/alpha-nvim",
  event = "User LazyVimStarted",
}

local button
local header
local buttons
local footer

function header()
  local header = {
    [[ ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
    [[ ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠋⠉⣉⣉⠙⠿⠋⣠⢴⣊⣙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
    [[ ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠋⠁⠀⢀⠔⡩⠔⠒⠛⠧⣾⠊⢁⣀⣀⣀⡙⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
    [[ ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠛⠁⠀⠀⠀⠀⠀⡡⠊⠀⠀⣀⣠⣤⣌⣾⣿⠏⠀⡈⢿⡜⣿⣿⣿⣿⣿⣿⣿⣿]],
    [[ ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠡⣤⣶⠏⢁⠈⢻⡏⠙⠛⠀⣀⣁⣤⢢⣿⣿⣿⣿⣿⣿⣿⣿]],
    [[ ⣿⣿⣿⣿⣿⣿⣿⣿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⣄⡀⠣⣌⡙⠀⣘⡁⠜⠈⠑⢮⡭⠴⠚⠉⠀⣿⣿⣿⣿⣿⣿⣿⣿]],
    [[ ⣿⣿⣿⣿⣿⣿⣿⠁⠀⢀⠔⠁⣀⣤⣤⣤⣤⣤⣄⣀⠀⠉⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠁⠀⢀⣠⢠⣿⣿⣿⣿⣿⣿⣿⣿]],
    [[ ⣿⣿⣿⣿⣿⣿⣿⡀⠀⢸⠀⢼⣿⣿⣶⣭⣭⣭⣟⣛⣛⡿⠷⠶⠶⢶⣶⣤⣤⣤⣶⣶⣾⡿⠿⣫⣾⣿⣿⣿⣿⣿⣿⣿⣿]],
    [[ ⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠈⠉⠉⠉⠉⠉⠙⠛⠛⠻⠿⠿⠿⠷⣶⣶⣶⣶⣶⣶⣶⣶⡾⢗⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
    [[ ⣿⣿⣿⣿⣿⣿⣿⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣿⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
    [[ ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣤⣄⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣝⡻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
    [[ ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
  }
  local h = {}
  local n = vim.api.nvim_win_get_height(0) - 40
  if n > 2 then
    n = math.floor(n / 2)
    for _ = 1, n do
      table.insert(h, "")
    end
  end
  for _, s in ipairs(header) do
    table.insert(h, s)
  end
  return {
    type = "text",
    val = h,
    opts = {
      position = "center",
      hl = "Comment",
    },
  }
end

function buttons()
  return {
    type = "group",
    val = {
      button(":Sessions", "⟳  Sessions", "Sessions"),
      button("<leader>to", "🗃 Old Files", function()
        require("telescope.builtin").oldfiles()
      end),
      button("<leader>tf", "  Find Files", function()
        require("telescope.builtin").find_files()
      end),
      button("<leader>tb", "  File Browser", function()
        require("telescope").extensions.file_browser.file_browser()
      end),
      button("<leader>tg", "☌  Live Grep", function()
        require("telescope.builtin").live_grep()
      end),
      button("<leader>gg", "  Git status", function()
        require("telescope.builtin").git_status()
      end),
      button(":Lazy", "  Plugins", "Lazy"),
      button(":Mason", "  Package Manager", "Mason"),
      button(":Noice", "⚠  Notifications", "Noice"),
    },
    opts = {
      spacing = 0,
    },
  }
end

function footer()
  local stats = require("lazy").stats()
  return {
    type = "text",
    val = {
      "Loaded " .. stats.count .. " plugins in " .. (math.floor(
        stats.startuptime * 100 + 0.5
      ) / 100) .. "ms",
    },
    opts = {
      position = "center",
      hl = "Comment",
    },
  }
end

local get_version

function M.config()
  local alpha = require "alpha"
  alpha.setup {
    layout = {
      { type = "padding", val = 2 },
      header(),
      { type = "padding", val = 1 },
      {
        type = "text",
        val = {
          get_version(),
        },
        opts = {
          position = "center",
          hl = "Number",
        },
      },
      { type = "padding", val = 1 },
      buttons(),
      { type = "padding", val = 2 },
      footer(),
    },
  }
  alpha.start(true)
end

function button(sc, txt, on_press)
  local opts = {
    position = "center",
    text = txt,
    shortcut = sc,
    cursor = 0,
    width = 44,
    align_shortcut = "right",
    hl_shortcut = "Comment",
    hl = "Normal",
  }

  return {
    type = "button",
    val = txt,
    on_press = function()
      if type(on_press) == "function" then
        on_press()
      elseif type(on_press) == "string" then
        vim.cmd(on_press)
      end
    end,
    opts = opts,
  }
end

function get_version()
  local version = vim.version()

  local s = version.major
  s = s .. "." .. version.minor
  s = s .. "." .. version.patch
  if version.prerelease then
    s = s .. " (prerelease)"
  end
  return s
end

return M
