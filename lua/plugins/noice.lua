--=============================================================================
-------------------------------------------------------------------------------
--                                                                   NOICE.NVIM
--=============================================================================
-- https://github.com/folke/noice.nvim
--_____________________________________________________________________________
-- A plugin that completely replaces the UI for messages, cmdline and the
-- popupmenu
--
-- commands:
--   :Noice - Open the messages history
------------------------------------------------------------------------------

local M = {
  "folke/noice.nvim",
  lazy = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
}

function M.config()
  require("noice").setup {
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
  }
end

---Display notify history in a telescope prompt
function M.notification_history()
  vim.api.nvim_exec("Noice telescope", false)
end

return M
