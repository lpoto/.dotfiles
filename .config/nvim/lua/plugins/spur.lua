--=============================================================================
--                                           https://github.com/lpoto/spur.nvim
--=============================================================================

local M
M = {
  "lpoto/spur.nvim",
  opts = {
    extensions = {
      --"dap",
      --"makefile",
      "json",
      "dbee",
      "codex"
    },
    mappings = {
      actions = { "<leader>s", mode = { "n" } },
    },
  },
  dependencies = {
    --{
    --  "mfussenegger/nvim-dap",
    --  cmd = { "DapToggleBreakpoint" },
    --  tag = "0.10.0"
    --},
    --{
    --  "theHamsta/nvim-dap-virtual-text",
    --  commit = "fbdb48c",
    --  opts = {}
    --},
    {
      "kndndrj/nvim-dbee",
      tag = "v0.1.9",
      opts = {
        window_layout = {
          is_open = function() return false end,
          open = function() end,
          close = function() end
        }
      },
      build = function()
        vim.schedule(function()
          M.init()
          require "dbee".install()
        end)
      end,
    }
  },
  keys = {
    { "<leader>s", function() require "spur".select_job() end },
    { "<leader>o", function() require "spur".toggle_output() end },
    { "<leader>c", function() require "spur".select_job("[Codex]") end },
    { "<leader>d", function() require "spur".select_job("[Database]") end },
    -- { "<leader>db", function() vim.cmd "DapToggleBreakpoint" end },
    -- { "<leader>dc", function() vim.cmd "DapClearBreakpoints" end },
  },
}

function M.init()
  -- NOTE: Disable dbee's default ui, so
  -- that we don't need nui plugin
  local packages_to_ignore = {
    "dbee.api.ui",
    "dbee.ui",
    "dbee.ui.common.floats",
    "dbee.ui.drawer",
    "dbee.ui.drawer.convert",
    "dbee.ui.editor",
    "dbee.ui.call_log",
  }
  for _, pkg in ipairs(packages_to_ignore) do
    if not package.loaded[pkg] then
      package.loaded[pkg] = {}
    end
  end
end

return M
