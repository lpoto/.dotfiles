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

function M.command()
  vim.api.nvim_create_user_command("Docker", function(opts)
    if type(opts.args) ~= "string" then
      return
    end
    if opts.args:match "^i" then
      require("telescope").extensions.docker.images()
      return
    end
    if opts.args:match "^c.*m" then
      require("telescope").extensions.docker.compose()
      return
    end
    require("telescope").extensions.docker.docker()
  end, {
    nargs = "?",
    complete = function(c)
      local util = require "config.util"
      local items = { "containers", "images", "compose" }
      table.sort(items, function(a, b)
        return util.string_matching_score(c, a)
          > util.string_matching_score(c, b)
      end)
      return items
    end,
  })
end

function M.config()
  M.command()

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
