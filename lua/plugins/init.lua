--=============================================================================
-------------------------------------------------------------------------------
--                                                                      PLUGINS
--=============================================================================
-- All plugins are required in this module's setup function.
-- The plugins are instealled with Packer.nvim:
-- https://github.com/wbthomason/packer.nvim
-- Most of them are lazily loaded and define ways to load them
-- dynamicly when needed.
--_____________________________________________________________________________

local plugins = {}

local ensure_packer

---Manually load the packer.nvim package and use it
---to load all the required plugins.
function plugins.setup()
  --NOTE: make sure the packer.nvim is available, if not, install it
  local packer = ensure_packer()
  if packer == nil then
    return
  end

  --NOTE: add all the required plugins with the packer

  packer.startup(function(use)
    --------------------------------------------------------------- PACKER.NVIM
    -- add packer as it's own package, so it is in opt not start directory,
    -- otherwise it tried to remove itself
    use { "wbthomason/packer.nvim", opt = true }
    -------------------------------------------------------------- GRUVBOX.NVIM
    -- gruvbox colorscheme
    use {
      "ellisonleao/gruvbox.nvim",
      config = function()
        require("plugins.gruvbox").setup()
      end,
    }
    ----------------------------------------------------------- NVIM-TREESITTER
    -- provide a simple and easy way to use the interface for
    -- tree-sitter in Neovim and provide some basic functionality
    -- such as highlighting based on it
    use {
      "nvim-treesitter/nvim-treesitter",
      config = function()
        require "plugins.treesitter"
      end,
      run = { ":TSUpdate" },
    }
    -------------------------------------------------------------- ACTIONS.NVIM
    -- manage and synchronously run actions
    use {
      "lpoto/actions.nvim",
      opt = true,
      cmd = require("plugins.actions").commands,
      config = function()
        require("plugins.actions").setup()
      end,
    }
    -------------------------------------------------------------- LUALINE.NVIM
    -- An easy way to configure neovim's statusline.
    use {
      "nvim-lualine/lualine.nvim",
      opt = true,
      event = "BufNewFile,BufReadPre",
      config = function()
        require "plugins.lualine"
      end,
    }
    ----------------------------------------------------- INDENT-BLANKLINE.NVIM
    -- Display thin vertical lines at each indentation level
    -- for code indented with spaces.
    use {
      "lukas-reineke/indent-blankline.nvim",
      opt = true,
      event = "BufNewFile,BufReadPre",
      config = function()
        require "plugins.indentline"
      end,
    }
    ------------------------------------------------------------------ NVIM-DAP
    -- A Debug Adapter Protocol client implementation for Neovim.
    use {
      "mfussenegger/nvim-dap",
      opt = true,
      cmd = require("plugins.dap").commands,
      config = function()
        require("plugins.dap").setup()
      end,
      requires = {
        -- A UI for nvim-dap which provides a good out of the box configuration
        -- A Neovim git wrapper
        {
          "rcarriga/nvim-dap-ui",
          module = "dapui",
        },
        {
          "theHamsta/nvim-dap-virtual-text", -- requires treesitter
          module = "nvim-dap-virtual-text",
        },
      },
    }
    -------------------------------------------------------------------- NEOGIT
    -- Neovim Git intergration
    use {
      "TimUntersberger/neogit",
      opt = true,
      cmd = require("plugins.neogit").commands,
      config = function()
        require("plugins.neogit").setup()
      end,
      --NOTE: this requires plenary.nvim
    }
    ------------------------------------------------------------ TELESCOPE.NVIM
    -- A highly extendable fuzzy finder over lists.
    use {
      "nvim-telescope/telescope.nvim",
      opt = true,
      keys = require("plugins.telescope").keymaps,
      config = function()
        require("plugins.telescope").setup()
        --NOTE: this requires plenary.nvim
      end,
      requires = {
        -- File browser extension for the telescope
        module_pattern = "telescope",
        "nvim-telescope/telescope-file-browser.nvim",
      },
    }
    ------------------------------------------------------------ FORMATTER.NVIM
    -- A format runner for Neovim.
    use {
      "mhartington/formatter.nvim",
      opt = true,
      cmd = require("plugins.formatter").commands,
      keys = require("plugins.formatter").keymaps,
      config = function()
        require("plugins.formatter").setup()
      end,
    }
    ------------------------------------------------------------ NVIM-LSPCONFIG
    -- Configs for the Nvim LSP client
    use {
      "neovim/nvim-lspconfig",
      opt = true,
      module_pattern = "lspconfig*",
      config = function()
        require("plugins.lspconfig").setup()
      end,
      requires = {
        -------------------------------------------------------------- NVIM-CMP
        -- autocompletion
        {
          "hrsh7th/nvim-cmp",
          config = function()
            require("plugins.cmp").setup()
          end,
          requires = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            {
              ----------------------------------------------------------- VSNIP
              -- autocompletion with snippers
              "hrsh7th/cmp-vsnip",
              requires = {
                "hrsh7th/vim-vsnip",
              },
            },
            ---------------------------------------------------- NVIM-AUTOPAIRS
            -- autocomplete matching parentheses etc.
            {
              "windwp/nvim-autopairs",
              module_pattern = { "cmp.*", "nvim-autopairs.*" },
            },
          },
        },
      },
    }
    -------------------------------------------------------------- PLENARY.NVIM
    -- used as dependency for some plugins
    use {
      "nvim-lua/plenary.nvim",
      opt = true,
      module_pattern = { "plenary.*" },
    }
  end)
end

---Ensure that packer.nvim package exists, if it does
---not, install it.
---@return table?
ensure_packer = function()
  vim.api.nvim_exec("packadd packer.nvim", false)

  local ok, packer = pcall(require, "packer")

  if ok == true then
    return packer
  end

  local install_path = vim.fn.stdpath "data"
    .. "/site/pack/packer/start/packer.nvim"

  vim.notify("Installing packer.nvim", vim.log.levels.INFO)

  ok, packer = pcall(vim.fn.system, {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  if ok == false then
    vim.notify(packer, vim.log.levels.ERROR)
    return nil
  end
  vim.api.nvim_exec("packadd packer.nvim", false)
  return require "packer"
end

return plugins
