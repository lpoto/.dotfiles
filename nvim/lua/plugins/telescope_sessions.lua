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
    function()
      Util.require(
        "telescope",
        function(telescope) telescope.extensions.sessions.sessions() end
      )
    end,
    mode = "n",
  },
}

function M.config()
  vim.api.nvim_create_user_command("Sessions", function()
    Util.require(
      "telescope",
      function(telescope) telescope.extensions.sessions.sessions() end
    )
  end, {})
  Util.require("telescope", function(telescope)
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
  end)
end

return M
