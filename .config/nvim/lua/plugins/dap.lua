--=============================================================================
--                                     https://github.com/mfussenegger/nvim-dap
--[[===========================================================================

Keymaps:
 - "<leader>d"   - open dap interface - all actions are available from here

-----------------------------------------------------------------------------]]

local M = {
  "mfussenegger/nvim-dap",
  dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
  cmd = { "DapToggleBreakpoint", "DapContinue" },
}

local util = {}

M.keys = {
  { "<leader>d", function() util.open() end },
}

function M.config()
  local dap, dapui = require "dap", require "dapui"
  dapui.setup {
    controls = {
      enabled = false,
    },
    layouts = {
      {
        elements = {
          {
            id = "scopes",
            size = 0.75,
          },
          {
            id = "breakpoints",
            size = 0.25,
          },
        },
        position = "left",
        size = 50,
      },
      {
        elements = { {
          id = "console",
          size = 1,
        } },
        position = "bottom",
        size = 20,
      },
    },
    icons = {
      collapsed = " ",
      current_frame = "*",
      expanded = " ",
    },
  }
  vim.fn.sign_define("DapBreakpoint", {
    text = "B",
    texthl = "Keyword",
  })
  vim.fn.sign_define("DapStopped", {
    text = "B",
    linehl = "Constant",
    texthl = "Keyword",
  })
  dap.listeners.before.attach.dapui_config = function()
    util.did_run = true
    util.open "console"
  end
  dap.listeners.before.continue.dapui_config = function() util.open "console" end
  dap.listeners.before.launch.dapui_config = function()
    util.did_run = true
    util.open "console"
  end
end

function util.open(element)
  local dap, dapui = require "dap", require "dapui"
  local configs = dap.configurations

  local is_running = dap.session() ~= nil

  if vim.bo.filetype:find "^dapui_" then vim.fn.execute "normal q" end

  if not is_running then
    -- TODO: Instead of only allowing running running configs
    -- of the same filetype as current buffer, I should allow
    -- running all configurations (that may be run from anywhere)
    if type(configs) ~= "table" or not configs[vim.bo.filetype] then
      vim.notify(
        "No DAP configuration found for " .. vim.bo.filetype,
        vim.log.levels.WARN
      )
      return
    end
  end

  local function on_select(el)
    vim.schedule(function()
      if el == nil then return end
      if el == "continue" then
        dap.continue()
        return
      end
      if el == "toggle breakpoint" then
        dap.toggle_breakpoint()
        return
      end
      if el:find "^step" then
        dap[el:gsub(" ", "_")]()
        return
      end
      dapui.float_element(el, {
        width = vim.fn.round(vim.o.columns - 1),
        height = vim.fn.round(vim.o.lines - 3),
        enter = true,
      })
    end)
  end

  local opts = { "continue" }
  if util.did_run or is_running then table.insert(opts, "console") end
  if is_running then
    table.insert(opts, "scopes")
    table.insert(opts, "step over")
    table.insert(opts, "step into")
    table.insert(opts, "step out")
  end
  table.insert(opts, "toggle breakpoint")
  table.insert(opts, "breakpoints")

  if element == nil then
    vim.ui.select(opts, { prompt = "[DAP] Choose action: " }, on_select)
  else
    on_select(element)
  end
end

return M
