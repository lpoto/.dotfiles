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
        init_term = function(cmd, env)
          if vim.fn.executable "tmux" ~= 1 then
            vim.notify("tmux not executable", vim.log.levels.WARN, {
              title = "Telescope Docker Tmux",
            })
            return
          end
          if type(cmd) == "table" then
            cmd = table.concat(cmd, " ")
          end
          local s = ""
          if type(env) == "table" then
            for k, v in ipairs(env) do
              s = s .. " " .. k .. "=" .. v
            end
          end
          cmd = s .. " " .. cmd
          vim.cmd("!tmux split-window -h " .. cmd)
        end,
      },
    },
  }

  telescope.load_extension "docker"
end

return M
