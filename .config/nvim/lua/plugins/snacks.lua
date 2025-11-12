--=============================================================================
--                                         https://github.com/folke/snacks.nvim
--=============================================================================

local function picker(name, config)
  return function() require "snacks.picker"[name](config) end
end

local M = {
  "folke/snacks.nvim",
  lazy = false,
  tag = "v2.23.0",
  priority = 1000,
  opts = {
    lazygit = { enabled = true },
    notifier = { enabled = true },
    terminal = { enabled = false },
    input = { enabled = false },
    toggle = { enabled = false },
    bigfile = {
      enabled = true,
      notify = true,
      size = 2 * 1024 * 1024,
      line_length = 100000,
    },
    image = {
      enabled = true,
      force = true,
    },
    picker = {
      enabled = true,
      ui_select = true,
      main = {
        file = false,
      },
      icons = {
        files = {
          enabled = false,
        },
      },
      win = {
        input = {
          keys = {
            ["<CR>"] = { "confirm", mode = { "n", "i" } },
            ["<Down>"] = { "list_down", mode = { "n", "i" } },
            ["<Up>"] = { "list_up", mode = { "n", "i" } },
            ["<Esc>"] = { "close", mode = { "n", "i" } },
            ["<c-p>"] = { "select_and_prev", mode = { "n", "i" } },
            ["<c-n>"] = { "select_and_next", mode = { "n", "i" } },
            ["<TAB>"] = { "list_down", mode = { "n", "i" } },
            ["<S-TAB>"] = { "list_up", mode = { "n", "i" } },
          },
        },
        list = {
          keys = {
            ["<CR>"] = "confirm",
            ["<Down>"] = "list_down",
            ["<Esc>"] = "close",
            ["<c-p>"] = { "select_and_prev", mode = { "n", "x" } },
            ["<c-n>"] = { "select_and_next", mode = { "n", "x" } },
            ["<Up>"] = "list_up",
            ["<TAB>"] = "list_down",
            ["<S-TAB>"] = "list_up",
          },
        },
      },
    },
  },
  keys = {
    { "<leader><space>", picker "smart" },
    { "<leader>n",       picker "files" },
    { "<leader>l",       picker "grep" },
    { "<leader>L",       picker "grep_word" },
    { "<leader><cr>",    picker "resume" },
    { "<leader>m",       picker "marks" },
    { "<leader>h",       picker "help" },
    { "gd",              picker "lsp_definitions" },
    { "gi",              picker "lsp_implementations" },
    { "gr",              picker "lsp_references" },
    { "gt",              picker "lsp_type_definitions" },
    { "<leader>q",       picker "qflist" },
    { "B",               picker "buffers" },
    {
      "<leader>e",
      function()
        if not vim.diagnostic.open_float() then
          picker "diagnostics_buffer" ()
        end
      end,
    },
    { "<leader>E", picker "diagnostics" },
    { "<leader>g", function() require "snacks".lazygit() end },
    { "<leader>G", function() require "snacks".git.blame_line() end },
  },
}

local add_git_as_spur_job
function M.init()
  vim.api.nvim_create_autocmd("User", {
    pattern = "SpurInit",
    callback = function()
      pcall(add_git_as_spur_job)
    end
  })
  vim.api.nvim_create_autocmd("BufNew", {
    callback = function(opts)
      if vim.bo[opts.buf].buftype ~= "" then return end
      vim.schedule(function()
        if vim.bo[opts.buf].buftype == "quickfix" then
          pcall(function()
            local win = vim.fn.bufwinid(opts.buf)
            vim.api.nvim_buf_delete(opts.buf, { force = true })
            vim.api.nvim_win_close(win, true)
          end)
          picker "qflist" ()
        end
      end)
    end
  })
end

function add_git_as_spur_job()
  local SpurJob = require "spur.core.job"
  local SpurGitJob = setmetatable({}, { __index = SpurJob })
  SpurGitJob.__index = SpurGitJob
  SpurGitJob.__type = "SpurJob"
  SpurGitJob.__subtype = "SpurGitJob"
  SpurGitJob.__metatable = SpurGitJob

  function SpurGitJob:new()
    local opts = {
      order = -90,
      type = "lazygit",
      job = {
        cmd = "lazygit",
        name = "[Git]",
      }
    }
    local spur_job = SpurJob:new(opts)
    local instance = setmetatable(spur_job, SpurGitJob)
    ---@diagnostic disable-next-line
    return instance
  end

  function SpurGitJob:is_running()
    return false
  end

  function SpurGitJob:can_run()
    return true
  end

  function SpurGitJob:run()
    require "snacks".lazygit()
  end

  function SpurGitJob:__tostring()
    return string.format("SpurGitJob(%s)", self:get_name())
  end

  local SpurJobHandler = require "spur.core.handler"
  local SpurJobGitHandler = setmetatable({}, { __index = SpurJobHandler })
  SpurJobGitHandler.__index = SpurJobGitHandler
  SpurJobGitHandler.__type = "SpurHandler"
  SpurJobGitHandler.__subtype = "SpurJobGitHandler"
  SpurJobGitHandler.__metatable = SpurJobGitHandler

  function SpurJobGitHandler:new()
    local handler = SpurJobHandler:new()
    local instance = setmetatable(handler, SpurJobGitHandler)
    return instance
  end

  function SpurJobGitHandler:accepts_job(opts, action)
    if type(opts) ~= "table" then
      return false
    end
    if type(action) ~= "string" or action == "" then
      return false
    end
    return opts.type == "lazygit"
  end

  function SpurJobGitHandler:create_job()
    ---@diagnostic disable-next-line
    return SpurGitJob:new()
  end

  function SpurJobGitHandler:__get_job_actions()
    return { { label = "Run", value = "run" } }
  end

  local manager = require "spur.manager"
  if not manager.is_initialized() then
    manager.init()
  end
  local handler = SpurJobGitHandler:new()
  manager.add_handler(handler)
  manager.add_job { type = "lazygit" }
end

return M
