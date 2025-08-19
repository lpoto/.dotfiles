--=============================================================================
--                                    https://github.com/zbirenbaum/copilot.lua
--=============================================================================
local util = {}

local M = {
  "zbirenbaum/copilot.lua",
  commit = "0f2fd38",
  dependencies = {
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      commit = "44f3758",
      cmd = { "CopilotChat", "CopilotChatLoad" },
      opts = {
        model = "gpt-4.1",
      },
      keys = {
        { "<leader>c", function() util.toggle_copilot_chat() end, mode = { "n" } },
        { "<leader>C", function() util.load_copilot_chat() end,   mode = { "n" } },
        { "<leader>c", function() util.load_copilot_chat() end,   mode = { "v" } }
      },
    },
    {
      "nvim-lua/plenary.nvim",
      commit = "b9fd522",
    },
    {
      "fang2hou/blink-copilot",
      commit = "41e91a6",
      opts = {
        debounce = 200,
      }
    },
  },
}

function M.config()
  local copilot = require "copilot"
  copilot.setup {
    suggestion = { enabled = false },
    panel = { enabled = false },
  }
  local has_cmp, cmp = pcall(require, "blink.cmp")
  if has_cmp then
    -- Add Copilot as a source to blink.cmp, instead
    -- of having suggestiongs as virtual text,
    -- so that they are all in the same place

    ---@diagnostic disable-next-line
    table.insert(require "blink.cmp.config".sources.default, "copilot")
    cmp.add_source_provider("copilot", {
      score_offset = 95,
      min_keyword_length = 0,
      max_items = 3,
      name = "copilot",
      module = "blink-copilot",
      enabled = function() return true end,
      async = true,
      override = {
        get_trigger_characters = function(_)
          --- We allow empty string and space as trigger characters
          --- for Copilot, so that it can trigger
          --- on empty lines or when the user types a space.
          return { " ", "" }
        end
      }
    })
  end
end

function M.init()
  --- lazy load copilot until
  --- the user enters insert mode in a
  --- proper buffer
  local group = vim.api.nvim_create_augroup("CopilotInit", { clear = true })
  local autocmd_id
  autocmd_id = vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      vim.schedule(function()
        local filetype = vim.bo.filetype
        if type(filetype) ~= "string"
          or filetype == ""
          or filetype == "oil"
          or filetype == "markdown"
          or filetype:match "^copilot"
          or filetype:match "^git"
          or filetype:match "^snacks"
        then
          return
        end
        vim.api.nvim_del_autocmd(autocmd_id)
        require "copilot"
      end)
    end,
  })
end

function util.close_copilot_chat()
  if not util.is_copilot_chat_open() then
    return false
  end
  vim.cmd "CopilotChatClose"
  return true
end

function util.is_copilot_chat_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local filetype = vim.bo[buf].filetype
    if filetype == "copilot-chat" then
      return true
    end
  end
  return false
end

function util.toggle_copilot_chat()
  if not util.close_copilot_chat() then
    util.open_copilot_chat()
  end
end

function util.open_copilot_chat()
  vim.cmd "CopilotChat"
end

function util.load_copilot_chat()
  local result = vim.fn.input "Copilot Chat Load: "
  if result == nil or result == "" then
    return
  end
  if not util.is_copilot_chat_open() then
    util.open_copilot_chat()
  end
  vim.cmd("CopilotChatLoad " .. result)
end

return M
