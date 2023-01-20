--=============================================================================
-------------------------------------------------------------------------------
--                                                                         INIT
--[[===========================================================================

Ensure that Lazy.nvim (https://github.com/folke/lazy.nvim) is installed, then
set it up. All other configs are managed through lazy.

-----------------------------------------------------------------------------]]

vim.g["mapleader"] = " " -------------------------------  map <leader> to space

---@return string: Lazy.nvim's installation path
local function get_lazy_path()
  return table.concat({ vim.fn.stdpath "data", "lazy", "lazy.nvim" }, "/")
end

---Install lazy.nvim if neccessary
local function ensure_lazy()
  if not vim.loop.fs_stat(get_lazy_path()) then
    vim.notify("Lazy.nvim not found, installing...", vim.log.levels.INFO)

    local args = {
      "git",
      "clone",
      "--filter=blob:none",
      "--single-branch",
      "git@github.com:folke/lazy.nvim.git",
      get_lazy_path(),
    }

    vim.notify("Running: " .. table.concat(args, " "), vim.log.levels.DEBUG)

    vim.fn.system(args)

    vim.notify("Lazy.nvim installed", vim.log.levels.INFO)
  end
end

local function get_lazy_options()
  return {
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
end

ensure_lazy()
vim.opt.runtimepath:prepend(get_lazy_path())
require("lazy").setup("plugins", get_lazy_options())
