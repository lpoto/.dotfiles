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
  require("lazy").setup("plugins", get_lazy_options())
end

function ensure_lazy(lazy_path)
  if not vim.loop.fs_stat(lazy_path) then
    vim.notify("Lazy.nvim not found, installing...", vim.log.levels.INFO)
    local args = {
      "git",
      "clone",
      "--filter=blob:none",
      "--single-branch",
      "git@github.com:folke/lazy.nvim.git",
      lazy_path,
    }
    vim.notify("Running: " .. table.concat(args, " "), vim.log.levels.DEBUG)
    vim.fn.system(args)
    vim.notify("Lazy.nvim installed", vim.log.levels.INFO)
  end
end

function get_lazy_options()
  return {
    defaults = {
      lazy = true,
    },
    lockfile = table.concat(
      { vim.fn.stdpath "config", ".lazy.lock.json" },
      "/"
    ),
    root = vim.fn.stdpath "data" .. "/lazy",
    dev = {
      dir = vim.fn.stdpath "data" .. "/lazy",
    },
    checker = {
      enabled = true,
      notify = false,
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

load_lazy(vim.fn.stdpath "data" .. "/lazy/lazy.nvim")
