--=============================================================================
-------------------------------------------------------------------------------
--                                                                   NOICE.NVIM
--[[===========================================================================
https://github.com/folke/noice.nvim

A plugin that completely replaces the UI for messages, cmdline and the
popupmenu

commands:
  :Noice - Open the messages history or "<leader>M"
-----------------------------------------------------------------------------]]
local M = {
  "folke/noice.nvim",
  lazy = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
}

local notification_history
function M.config()
  Util.require("noice", function(noice)
    noice.setup({
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        message = {
          enabled = true,
          view = "mini",
        },
        progress = {
          enabled = true,
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
      cmdline = {
        format = {
          cmdline = { icon = ">" },
          search_down = { icon = " ?" },
          search_up = { icon = " ?" },
          filter = { icon = "$" },
          lua = { icon = "lua" },
          help = { icon = "?" },
        },
      },
      notify = {
        enabled = true,
        view = "mini",
      },
      messages = {
        enabled = true,
        view = "mini",
        view_error = "mini",
        view_warn = "mini",
        view_history = "messages",
        view_search = "mini",
      },
      routes = {
        {
          view = "cmdline",
          filter = { event = "msg_showmode" },
        },
      },
    })
    vim.defer_fn(function()
      vim.keymap.set("n", "<leader>M", notification_history)
    end, 100)
  end)
end

local telescope_config_loaded = false
local function telescope_config()
  if telescope_config_loaded then
    return
  end
  telescope_config_loaded = true
  Util.require("telescope", function(telescope)
    telescope.load_extension("noice")
  end)
end

---Display notify history in a telescope prompt
function notification_history()
  telescope_config()
  vim.api.nvim_exec("Telescope noice theme=ivy", false)
end

return M
