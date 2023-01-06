--=============================================================================
-------------------------------------------------------------------------------
--                                                                    LAZY.NVIM
--=============================================================================
-- https://github.com/folke/lazy.nvim
--_____________________________________________________________________________
-- A plugin manager for neovim, this configures and bootstraps it from github.
------------------------------------------------------------------------------
local path = require "util.path"
local lazypath = path.join(vim.fn.stdpath "data", "lazy", "lazy.nvim")

if not vim.loop.fs_stat(lazypath) then
  vim.notify("Lazy.nvim not found, installing...", vim.log.levels.INFO)

  local args = {
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "git@github.com:folke/lazy.nvim.git",
    lazypath,
  }

  vim.notify("Running: " .. table.concat(args, " "), vim.log.levels.DEBUG)

  vim.fn.system(args)

  vim.notify("Lazy.nvim installed", vim.log.levels.INFO)
end

vim.opt.runtimepath:prepend(lazypath)
local opts = {
  defaults = {
    lazy = true,
    version = "*",
  },
  lockfile = path.join(vim.fn.stdpath "config", ".lazy.lock.json"),
  dev = { patterns = jit.os:find "Windows" and {} or { "folke" } },
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
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  debug = false,
}

require("lazy").setup("plugins", opts)
