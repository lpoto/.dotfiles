--=============================================================================
-------------------------------------------------------------------------------
--                                                                    LAZY.NVIM
--=============================================================================
-- https://github.com/folke/lazy.nvim
--_____________________________________________________________________________
-- A plugin manager for neovim, this configures and bootstraps it from github.
------------------------------------------------------------------------------
local log = require "util.log"

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  log.warn "Lazy.nvim not found, installing..."

  local args = {
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "git@github.com:folke/lazy.nvim.git",
    lazypath,
  }

  log.info("Running: " .. table.concat(args, " "))

  vim.fn.system(args)

  log.warn "Lazy.nvim installed"
end

vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup("plugins", {
  defaults = { lazy = true },
  dev = { patterns = jit.os:find "Windows" and {} or { "folke" } },
  checker = { enabled = true },
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
})
