--=============================================================================
-------------------------------------------------------------------------------
--                                                                    LAZY NVIM
--[[===========================================================================

Ensure that Lazy.nvim (https://github.com/folke/lazy.nvim) is installed, then
set it up and load the plugins.

-----------------------------------------------------------------------------]]
local ensure_lazy, get_lazy_options

---Ensure the lazy.nvim plugin manager is installed. If not,
---intall it, then set it up and lazy load all the plugins in the
---./lua/plugins directory.
local function load_lazy(lazy_path)
  ensure_lazy(lazy_path)
  vim.opt.runtimepath:prepend(lazy_path)
  Util.require(
    "lazy",
    function(lazy) lazy.setup("plugins", get_lazy_options()) end
  )
end

function ensure_lazy(lazy_path)
  if not vim.loop.fs_stat(lazy_path) then
    vim.notify("Lazy.nvim not found, installing...", "info", "Lazy")
    ---@type table
    local cmd = {
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazy_path,
    }
    vim.notify({ "Running:", table.concat(cmd, " ") }, "info", "Lazy")
    local ok, err = pcall(vim.fn.system, cmd)
    if not ok then
      vim.notify({ "Error installing Lazy.nvim:", err }, "error", "Lazy")
      return
    end
    if not vim.loop.fs_stat(lazy_path) then
      vim.notify("Failed installing Lazy.nvim!", "error", "Lazy")
    else
      vim.notify(
        "Lazy.nvim installed!",
        "info",
        { title = "Lazy", delay = 200 }
      )
    end
  end
end

function get_lazy_options()
  return {
    defaults = {
      lazy = true,
    },
    lockfile = vim.fs.dirname(vim.fn.stdpath("config")) .. "/.lazy.lock.json",
    ui = {
      border = "rounded",
    },
    root = vim.fn.stdpath("data") .. "/lazy",
    dev = {
      dir = vim.fn.stdpath("data") .. "/lazy",
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
          "matchit",
          "matchparen",
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          --"zipPlugin",
        },
      },
    },
    debug = false,
  }
end

load_lazy(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")

Util.setup["lazy"] = function() vim.api.nvim_exec2("Lazy restore", {}) end
