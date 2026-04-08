--=============================================================================
--                                                               GITHUB COPILOT
--[[===========================================================================
--
-- Set up GitHub Copilot and integrate it as a blink.cmp source,
-- so the copletions are shown in the same popup as
-- the other completion sources, instead of as virtual text.
--
-- Relevant commands:
--
-- :Copilot <subcommand>     (copilot actions, such as auth,...)
--
-----------------------------------------------------------------------------]]

vim.pack.add {
  {
    src = "https://github.com/zbirenbaum/copilot.lua",
    version = "v2.0.1"
  },
  {
    src = "https://github.com/fang2hou/blink-copilot",
    version = "v1.4.1",
  }
}

--- lazy load copilot until the user enters insert mode in a proper buffer
local autocmd_id
autocmd_id = vim.api.nvim_create_autocmd("InsertEnter", {
  group = vim.api.nvim_create_augroup("CopilotInit", { clear = true }),
  callback = function()
    vim.schedule(function()
      local filetype = vim.bo.filetype
      if type(filetype) ~= "string"
        or filetype == ""
        or filetype == "oil"
        or filetype == "markdown"
        or filetype:match "bigfile"
        or filetype:match "^copilot"
        or filetype:match "^git"
        or filetype:match "^snacks"
      then
        return
      end
      -- NOTE: Delete autocmd, so this runs only once
      vim.api.nvim_del_autocmd(autocmd_id)

      require "copilot".setup {
        suggestion = { enabled = false },
        panel = { enabled = false },
        nes = { enabled = false },
        should_attach = function(buf_id, _)
          if not vim.bo[buf_id].buflisted then
            return false
          end
          if vim.bo[buf_id].buftype ~= "" then
            return false
          end
          return vim.bo[buf_id].filetype ~= "bigfile"
        end
      }
      local has_cmp, cmp = pcall(require, "blink.cmp")
      if has_cmp == true then
        ---@diagnostic disable-next-line
        require "blink-copilot".setup {}
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
          enabled = function()
            local ft = vim.bo.filetype
            if ft == "bigfile" then
              return false
            end
            return vim.bo.buftype == ""
          end,
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
    end)
  end,
})
