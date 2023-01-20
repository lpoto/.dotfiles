--=============================================================================
-------------------------------------------------------------------------------
--                                                                    LAZY.NVIM
--=============================================================================
-- https://github.com/folke/lazy.nvim
--_____________________________________________________________________________
-- A plugin manager for neovim, this configures and bootstraps it from github.
------------------------------------------------------------------------------
local lazy = {}

lazy.path = table.concat({ vim.fn.stdpath "data", "lazy", "lazy.nvim" }, "/")

lazy.config = function()
  if not vim.loop.fs_stat(lazy.path) then
    vim.notify("Lazy.nvim not found, installing...", vim.log.levels.INFO)

    local args = {
      "git",
      "clone",
      "--filter=blob:none",
      "--single-branch",
      "git@github.com:folke/lazy.nvim.git",
      lazy.path,
    }

    vim.notify("Running: " .. table.concat(args, " "), vim.log.levels.DEBUG)

    vim.fn.system(args)

    vim.notify("Lazy.nvim installed", vim.log.levels.INFO)
  end

  vim.opt.runtimepath:prepend(lazy.path)
  local opts = {
    defaults = {
      lazy = true,
      --version = "*",
    },
    lockfile = table.concat(
      { vim.fn.stdpath "config", ".lazy.lock.json" },
      "/"
    ),
    root = table.concat({ vim.fn.stdpath "data", "lazy" }, "/"),
    dev = {
      dir = table.concat({ vim.fn.stdpath "data", "lazy" }, "/"),
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
end

return lazy.config()
