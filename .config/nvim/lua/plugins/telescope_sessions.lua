--=============================================================================
-------------------------------------------------------------------------------
--                                                      TELESCOPE-SESSIONS.NVIM
--[[===========================================================================
https://github.com/lpotot/telescope-sessions.nvim

Commands:
  - :Sessions - Display all available sessions
              (<CR> - load session, <C-d> - delete session)

Keymaps:
  - <leader>s - same as :Sessions

-----------------------------------------------------------------------------]]

local M = {
  "lpoto/telescope-sessions.nvim",
  event = "VimLeavePre",
  cmd = "Sessions",
}

M.keys = {
  {
    "<leader>s",
    function() require("telescope").extensions.sessions.sessions() end,
    mode = "n",
  },
}

function M.config()
  vim.api.nvim_create_user_command(
    "Sessions",
    function() require("telescope").extensions.sessions.sessions() end,
    {}
  )
  local ok, telescope = pcall(require, "telescope")
  if not ok then return end
  telescope.setup({
    extensions = {
      sessions = {
        layout_config = {
          width = 130,
        },
      },
    },
  })
  telescope.load_extension("sessions")
end

return M
