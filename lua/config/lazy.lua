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
  Util.require("lazy", function(lazy)
    lazy.setup("plugins", get_lazy_options())
  end)
end

function ensure_lazy(lazy_path)
  if not vim.loop.fs_stat(lazy_path) then
    Util.log():info "Lazy.nvim not found, installing..."
    ---@type table
    local args = {
      "git",
      "clone",
      "--filter=blob:none",
      "--single-branch",
      "git@github.com:folke/lazy.nvim.git",
      lazy_path,
    }
    Util.log():info("Running:" .. vim.inspect(args))
    vim.fn.system(args)
    Util.log():info "Lazy.nvim installed"
  end
end

function get_lazy_options()
  return {
    defaults = {
      lazy = true,
    },
    lockfile = Util.path(vim.fn.stdpath "config", ".lazy.lock.json"),
    root = Util.path(vim.fn.stdpath "data", "lazy"),
    dev = {
      dir = Util.path(vim.fn.stdpath "data", "lazy"),
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

load_lazy(Util.path(vim.fn.stdpath "data", "lazy", "lazy.nvim"))
