--=============================================================================
-------------------------------------------------------------------------------
--                                                             PERSISTENCE.NVIM
--=============================================================================
-- https://github.com/folke/persistence.nvim
--_____________________________________________________________________________

--[[
Automated session management.

Keymaps:
  - <leader>s - Display all available sessions
              - NOTE: delete session with <C-d>

NOTE: session is saved automatically when yout quit neovim.
--]]

local M = {
  "folke/persistence.nvim",
  event = "VimLeavePre",
  keys = { "<leader>s" },
  dir = vim.fn.stdpath "data" .. "/lazy/persistence",
}

function M.config()
  local mapper = require "util.mapper"

  require("persistence").setup {
    dir = vim.fn.stdpath "data" .. "/sessions/",
  }

  mapper.map(
    "n",
    "<leader>s",
    "<CMD>lua require('plugins.persistence').list_sessions()<CR>",
    {},
    true
  )
end

local function get_sessions()
  local sessions = {}
  local session_dir = vim.fn.stdpath "data" .. "/sessions/"
  for k, v in vim.fs.dir(session_dir) do
    if v == "file" then
      table.insert(sessions, k)
    end
  end
  return sessions
end

local function session_finder(results)
  local entry_display = require "telescope.pickers.entry_display"
  local finders = require "telescope.finders"

  return finders.new_table {
    results = results,
    entry_maker = function(line)
      return {
        value = line,
        ordinal = line,
        display = function(e)
          local displayer = entry_display.create {
            items = { { width = 0.99 } },
          }
          local v = e.value:gsub("%%", "/"):gsub(".vim$", "")
          return displayer { v }
        end,
      }
    end,
  }
end

local function delete_selected_session(prompt_bufnr)
  local action_state = require "telescope.actions.state"
  local picker = action_state.get_current_picker(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  local session_file = vim.fn.stdpath "data"
    .. "/sessions/"
    .. selection.value
  if vim.fn.delete(session_file) ~= 0 then
    vim.notify("Failed to delete session", vim.log.levels.WARN, {
      title = "Sessions",
    })
  else
    vim.notify("Session deleted", vim.log.levels.INFO, {
      title = "Sessions",
    })
    picker:refresh(session_finder(get_sessions()), { reset_prompt = true })
  end
end

local function select_session(prompt_bufnr)
  local action_state = require "telescope.actions.state"
  local actions = require "telescope.actions"

  local session_dir = vim.fn.stdpath "data" .. "/sessions/"
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  local session_file = session_dir .. selection.value
  if vim.fn.filereadable(session_file) == 1 then
    vim.cmd("silent! source " .. vim.fn.fnameescape(session_file))
  else
    vim.notify("Session file is not readable", vim.log.levels.WARN, {
      title = "Sessions",
    })
  end
end

function M.list_sessions()
  local pickers = require "telescope.pickers"
  local actions = require "telescope.actions"

  local sessions = get_sessions()
  if next(sessions) == nil then
    vim.notify("There are no available sessions", vim.log.levels.WARN, {
      title = "Sessions",
    })
    return
  end

  pickers
    .new(require("telescope.themes").get_ivy(), {
      prompt_title = "Sessions",
      hidden = true,
      finder = session_finder(sessions),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          select_session(prompt_bufnr)
        end)
        map({ "i", "n" }, "<C-d>", function()
          delete_selected_session(prompt_bufnr)
        end)
        map({ "n" }, "d", function()
          delete_selected_session(prompt_bufnr)
        end)

        return true
      end,
    })
    :find()
end

return M
