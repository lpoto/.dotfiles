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

local path = require "util.path"

local M = {
  "folke/persistence.nvim",
  event = "VimLeavePre",
  keys = { "<leader>s" },
  dir = path.join(vim.fn.stdpath "data", "lazy", "persistence"),
}

M.session_dir = path.join(vim.fn.stdpath "data", "sessions", "")

function M.config()
  local mapper = require "util.mapper"

  require("persistence").setup {
    dir = M.session_dir,
  }

  mapper.map(
    "n",
    "<leader>s",
    "<CMD>lua require('plugins.persistence').list_sessions()<CR>",
    {},
    true
  )
end

--- Get a table of all available sessions located
--- in the persistence.nivm's session directory.
--- The sessions are sorted by last modified time,
--- so the most recent session is at the top.
local function get_sessions()
  local sessions = {}
  for k, v in vim.fs.dir(M.session_dir) do
    if v == "file" then
      table.insert(sessions, k)
    end
  end
  -- NOTE: Sort session so that the most recent is at the top
  table.sort(sessions, function(a, b)
    a = path.join(M.session_dir, a)
    b = path.join(M.session_dir, b)
    return vim.loop.fs_stat(a).mtime.sec > vim.loop.fs_stat(b).mtime.sec
  end)
  return sessions
end

--- Create a telescope finder for all available sessions.
--- The dinfer displays the session name and the last modified time.
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
            separator = " ",
            items = {
              { width = 30 },
              { remaining = true },
            },
          }
          local time = vim.fn.strftime(
            "%c",
            vim.fn.getftime(path.join(M.session_dir, e.value))
          )
          local value = e.value:gsub(".vim$", ""):gsub("%%", "/")
          return displayer { { time, "Comment" }, value }
        end,
      }
    end,
  }
end

---Delete the session selected in a telescope prompt
local function delete_selected_session(prompt_bufnr)
  local action_state = require "telescope.actions.state"
  local picker = action_state.get_current_picker(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  local session_file = M.session_dir .. selection.value
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

---Load the session selected in a telescope prompt
local function select_session(prompt_bufnr)
  local action_state = require "telescope.actions.state"
  local actions = require "telescope.actions"

  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  local session_file = M.session_dir .. selection.value
  if vim.fn.filereadable(session_file) == 1 then
    vim.cmd("silent! source " .. vim.fn.fnameescape(session_file))
  else
    vim.notify("Session file is not readable", vim.log.levels.WARN, {
      title = "Sessions",
    })
  end
end

---List all available sessions in a telescope prompt.
---The sessions may then be selected (loaded) or deleted.
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
