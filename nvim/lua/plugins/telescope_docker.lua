--=============================================================================
-------------------------------------------------------------------------------
--                                                        TELESCOPE-DOCKER-NVIM
--[[===========================================================================
https://github.com/lpoto/telescope-docker.nvim

Handle docker containers, images and compose files from a prompt.

commands:
  :Docker {containers|images|compose|files|machines|swarm} -
        show a list of containers, images or compose files
-----------------------------------------------------------------------------]]
local M = {
  "lpoto/telescope-docker.nvim",
  cmd = "Docker",
}

function M.command()
  vim.api.nvim_create_user_command("Docker", function(opts)
    if type(opts.args) ~= "string" then
      return
    end
    local f = "docker"
    if opts.args:match "^i" then
      f = "images"
    elseif opts.args:match "^f" then
      f = "files"
    elseif opts.args:match "^s" then
      f = "swarm"
    elseif opts.args:match "^v" then
      f = "volumes"
    elseif opts.args:match "^n" then
      f = "networks"
    elseif opts.args:match "^c.*m" then
      f = "compose"
    elseif opts.args:match "^m" then
      f = "machines"
    elseif opts.args:match "^c.*e" or opts.args:match "^c.*x" then
      f = "contexts"
    elseif opts.args:match "^c" then
      f = "containers"
    end
    Util.require("telescope", function(telescope)
      telescope.extensions.docker[f]()
    end)
  end, {
    nargs = "?",
    complete = function(c)
      local items = {
        "containers",
        "images",
        "compose",
        "files",
        "machines",
        "swarm",
        "volumes",
        "networks",
        "contexts",
      }
      table.sort(items, function(a, b)
        return Util.string_matching_score(c, a)
          > Util.string_matching_score(c, b)
      end)
      return items
    end,
  })
end

function M.config()
  M.command()

  Util.require("telescope", function(telescope)
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
  end)
end

return M
