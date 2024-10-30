--=============================================================================
--                                           https://github.com/folke/lazy.nvim
--=============================================================================
if vim.g.did_lazy or vim.api.nvim_set_var("did_lazy", true) then return end

local M = {
  plugins_root = "plugins",
  path = vim.fn.stdpath "data" .. "/lazy/lazy.nvim",
}

---Ensure the lazy.nvim plugin manager is installed. If not,
---intall it, then set it up and lazy load all the plugins in the
---./lua/plugins directory.
function M.init()
  if M.__initialized then return M end
  M.__initialized = true
  M.ensure_lazy(M.path)
  vim.opt.runtimepath:prepend(M.path)
  local ok, lazy = pcall(require, "lazy")
  if ok then lazy.setup(M.plugins_root, M.get_lazy_options()) end
  return M
end

function M.ensure_lazy(lazy_path)
  ---@diagnostic disable-next-line
  if not vim.uv.fs_stat(lazy_path) then
    print "Lazy.nvim not found, installing..."
    ---@type table
    local cmd = {
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazy_path,
    }
    print("Running: " .. table.concat(cmd, " "))
    local ok, err = pcall(vim.fn.system, cmd)
    if not ok then
      vim.notify("Error installing Lazy.nvim: " .. err, vim.log.levels.INFO)
      return
    end
    ---@diagnostic disable-next-line
    if not vim.uv.fs_stat(lazy_path) then
      print "[ERROR] Failed installing Lazy.nvim!"
    else
      print "Lazy.nvim installed!"
    end
  end
end

function M.get_lazy_options()
  return {
    defaults = {
      lazy = true,
    },
    root = vim.fn.stdpath "data" .. "/lazy",
    lockfile = vim.fn.stdpath "config" .. "/.lazy_lock.json",
    state = vim.fn.stdpath "state" .. "/lazy.json",
    ui = {
      border = "rounded",
      icons = {
        cmd = "⌘",
        config = "🛠",
        event = "📅",
        ft = "📂",
        init = "⚙",
        keys = "🗝",
        plugin = "🔌",
        runtime = "💻",
        require = "🌙",
        source = "📄",
        start = "🚀",
        task = "📌",
        lazy = "💤 ",
      },
    },
    dev = {
      ---@diagnostic disable-next-line
      path = vim.uv.os_homedir() .. "/personal/nvim/plugins",
    },
    install = {
      missing = true,
      colorscheme = { "default" },
    },
    checker = {
      enabled = true,
      notify = false,
    },
    change_detection = {
      enabled = false,
    },
    diff = {
      cmd = "terminal_git",
    },
    performance = {
      cache = {
        enabled = true,
      },
      rtp = {
        disabled_plugins = {
          --"gzip",
          --"zipPlugin",
          --'tarPlugin',
          --"matchit",
          --"matchparen",
          "netrwPlugin",
          "tohtml",
          "tutor",
        },
      },
    },
    debug = false,
  }
end

return M.init()
