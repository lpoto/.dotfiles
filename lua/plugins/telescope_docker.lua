--=============================================================================
-------------------------------------------------------------------------------
--                                                        TELESCOPE-DOCKER-NVIM
--=============================================================================
-- https://github.com/lpoto/telescope-docker.nvim
--_____________________________________________________________________________

--[[
Handle docker containers, images and compose files from a prompot.

Keymaps:
  - "<leader>d" - containers
  - "<leader>di" - images
  - "<leader>dc" - docker-compose files
--]]

local M = {
  "lpoto/telescope-docker.nvim",
}

function M.init()
  vim.keymap.set("n", "<leader>d", function()
    require("telescope").extensions.docker.docker()
  end)
  vim.keymap.set("n", "<leader>di", function()
    require("telescope").extensions.docker.images()
  end)
  vim.keymap.set("n", "<leader>dc", function()
    require("telescope").extensions.docker.compose()
  end)
end

function M.config()
  local telescope = require "telescope"
  telescope.setup {
    extensions = {
      docker = {
        theme = "ivy",
        log_level = vim.log.levels.INFO,
        init_term = function(command)
          vim.cmd "FloatermNew"
          vim.cmd("FloatermSend " .. command)
        end,
      },
    },
  }

  telescope.load_extension "docker"
end

return M
