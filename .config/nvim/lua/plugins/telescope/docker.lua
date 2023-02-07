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

M.keys = {
  {
    "<leader>d",
    function()
      require("telescope").extensions.docker.docker()
    end,
    mode = "n",
  },
  {
    "<leader>di",
    function()
      require("telescope").extensions.docker.images()
    end,
    mode = "n",
  },
  {
    "<leader>dc",
    function()
      require("telescope").extensions.docker.compose()
    end,
    mode = "n",
  },
}

function M.config()
  local telescope = require "telescope"
  telescope.setup {
    extensions = {
      docker = {
        theme = "ivy",
        log_level = vim.log.levels.INFO,
        initial_mode = "normal",
        init_term = "vsplit new",
      },
    },
  }

  telescope.load_extension "docker"
end

return M
