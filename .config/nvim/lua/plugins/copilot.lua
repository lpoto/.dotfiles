--=============================================================================
--                                    https://github.com/zbirenbaum/copilot.lua
--=============================================================================
local M = {
  "zbirenbaum/copilot.lua",
  commit = "2d75114",
  dependencies = {
    {
      "fang2hou/blink-copilot",
      tag = "v1.4.1",
    },
  },
}

function M.config()
  local copilot = require "copilot"
  copilot.setup {
    suggestion = { enabled = false },
    panel = { enabled = false },
    nes = { enabled = false },
  }
  local has_cmp, cmp = pcall(require, "blink.cmp")
  if has_cmp then
    -- Add Copilot as a source to blink.cmp, instead
    -- of having suggestiongs as virtual text,
    -- so that they are all in the same place

    ---@diagnostic disable-next-line
    table.insert(require "blink.cmp.config".sources.default, "copilot")
    cmp.add_source_provider("copilot", {
      score_offset = 90,
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

return M
