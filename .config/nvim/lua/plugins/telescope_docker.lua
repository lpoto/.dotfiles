--=============================================================================
-------------------------------------------------------------------------------
--                                                        TELESCOPE-DOCKER-NVIM
--=============================================================================
-- https://github.com/lpoto/telescope-docker.nvim
--_____________________________________________________________________________

--[[
Handle docker containers, images and compose files from a prompt.

commands:
  :Docker {containers|images|compose} - show a list of containers,
                                       images or compose files
--]]
local M = {
  "lpoto/telescope-docker.nvim",
  cmd = "Docker",
}

function M.init()
  vim.api.nvim_create_user_command("Docker", function(opts)
    if type(opts.args) ~= "string" then
      return
    end
    if opts.args:match "im" then
      require("telescope").extensions.docker.images()
      return
    end
    if opts.args:match "comp" then
      require("telescope").extensions.docker.compose()
      return
    end
    require("telescope").extensions.docker.docker()

  end,
  {

    nargs = "?",
    complete = function()
      return { "containers", "images", "compose" }
    end,
  })
end

function M.config()
  local telescope = require "telescope"
  telescope.setup {
    extensions = {
      docker = {
        theme = "ivy",
        log_level = vim.log.levels.INFO,
        initial_mode = "normal",
      },
    },
  }

  telescope.load_extension "docker"
end

return M
