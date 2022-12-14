--=============================================================================
-------------------------------------------------------------------------------
--                                                                      PLUGINS
--=============================================================================
-- NOTE: all plugins' config are defined in lua/plugins/*
-------------------------------------------------------------------------------

local Plugin = require "util.packer.wrapper"
local packer = require "util.packer"

--add all the required plugins with the packer
packer.startup(function(use)
  ----------------------------------------------------------------- PACKER.NVIM
  -- add packer as it's own package, so it is in opt not start directory,
  -- otherwise it tried to remove itself
  use { "wbthomason/packer.nvim", opt = true }
  ---------------------------------------------------------------- GRUVBOX.NVIM
  -- gruvbox colorscheme
  Plugin.new(use, {
    "ellisonleao/gruvbox.nvim",
    as = "gruvbox",
  })
  ------------------------------------------------------------- NVIM-TREESITTER
  -- provide a simple and easy way to use the interface for
  -- tree-sitter in Neovim and provide some basic functionality
  -- such as highlighting based on it
  Plugin.new(use, {
    "nvim-treesitter/nvim-treesitter",
    as = "nvim-treesitter",
    run = ":TSUpdate",
  })
  -------------------------------------------------------------- GITHUB COPILOT
  -- GitHub Copilot uses OpenAI Codex to suggest code and
  -- entire functions in real-time right from your editor.
  Plugin.new(use, {
    "github/copilot.vim",
    as = "copilot",
    cmd = "Copilot",
    setup = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
    end,
  })
  ---------------------------------------------------------------- ACTIONS.NVIM
  -- manage and synchronously run actions
  Plugin.new(use, {
    "lpoto/actions.nvim",
    as = "actions",
    cmd = { "A", "Action", "Actions" },
  })
  ---------------------------------------------------------------- LUALINE.NVIM
  -- An easy way to configure neovim's statusline.
  Plugin.new(use, {
    "nvim-lualine/lualine.nvim",
    as = "lualine",
    event = "BufNewFile,BufReadPre",
  })
  ------------------------------------------------------- INDENT-BLANKLINE.NVIM
  -- Display thin vertical lines at each indentation level
  -- for code indented with spaces.
  Plugin.new(use, {
    "lukas-reineke/indent-blankline.nvim",
    as = "indentline",
    event = "BufNewFile,BufReadPre",
  })
  -------------------------------------------------------------------- NVIM-DAP
  -- A Debug Adapter Protocol client implementation for Neovim.
  Plugin.new(use, {
    "mfussenegger/nvim-dap",
    as = "dap",
    cmd = { "DapContinue", "DapToggleBreakpoint" },
    keys = { "<leader>c", "<leader>b" },
    requires = {
      {
        "theHamsta/nvim-dap-virtual-text", -- requires treesitter
        as = "dap-virtual-text",
        module = "nvim-dap-virtual-text",
      },
    },
  })
  ---------------------------------------------------------------------- NEOGIT
  -- Neovim Git intergration
  Plugin.new(use, {
    "TimUntersberger/neogit",
    as = "neogit",
    cmd = { "Git", "Neogit" },
    --NOTE: this requires plenary.nvim
  })
  -------------------------------------------------------------- TELESCOPE.NVIM
  -- A highly extendable fuzzy finder over lists.
  Plugin.new(use, {
    "nvim-telescope/telescope.nvim",
    as = "telescope",
    module = "telescope",
    keys = {
      "<leader>n",
      "<C-x>",
      "<leader>g",
      "<C-g>",
      "<C-n>",
      "<leader>d",
      "<leader>q",
    },
    requires = {
      -- File browser extension for the telescope
      "nvim-telescope/telescope-file-browser.nvim",
      as = "telescope-fzf-native",
      module_pattern = "telescope*",
    },
  })
  -------------------------------------------------------------- FORMATTER.NVIM
  -- A format runner for Neovim.
  Plugin.new(use, {
    "mhartington/formatter.nvim",
    as = "formatter",
    cmd = { "Format", "FormatWrite", "FormatLock", "FormatWriteLock" },
    keys = { "<leader>f" },
  })
  ------------------------------------------------------------------- NVIM-LINT
  -- A format runner for Neovim.
  Plugin.new(use, {
    "mfussenegger/nvim-lint",
    as = "lint",
    module = "lint",
  })
  -------------------------------------------------------------- NVIM-LSPCONFIG
  -- Configs for the Nvim LSP client
  Plugin.new(use, {
    "neovim/nvim-lspconfig",
    as = "lspconfig",
    cmd = "LspStart",
    requires = {},
  })
  -------------------------------------------------------------------- NVIM-CMP
  -- autocompletion
  Plugin.new(use, {
    "hrsh7th/nvim-cmp",
    as = "cmp",
    requires = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      "windwp/nvim-autopairs",
    },
  })
  ---------------------------------------------------------------- PLENARY.NVIM
  -- used as dependency for some plugins
  Plugin.new(use, {
    "nvim-lua/plenary.nvim",
    as = "plenary",
    module_pattern = "plenary.*",
  })
end)
