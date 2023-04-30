--=============================================================================
-------------------------------------------------------------------------------
--                                                                     SESSIONS
--[[===========================================================================
Automated session management with telescope.

Commands:
  - :Sessions - Display all available sessions

NOTE: session is saved automatically when yout quit neovim.
-----------------------------------------------------------------------------]]
local util = require "config.util"

local M = {}

---@type string: Path to the directory where sessions are saved
M.session_dir = util.path(vim.fn.stdpath "data", "sessions")

---@type table: A table of filetype patterns that will be ignored
---when saving sessions
M.ignore_filetype_patterns = {
  "git.*",
  "qf",
  "help",
  "undotree",
  "dashboard",
  "Neogit.*",
  "Telecope.*",
  "lazy",
  "null-ls-info",
  "Lsp.*",
  "mason",
  "SidebarNvim",
  "noice",
  "Neogit.*",
  "Diffview.*",
}

---@type string: Title used for logging, creating augroups,
---telescope prompts, etc.
M.title = "Sessions"

function M.init()
  vim.api.nvim_create_user_command("Sessions", function()
    M.list_sessions()
  end, {})
  vim.keymap.set("n", "<leader>s", "<cmd>Sessions<CR>")
  --- Create an autocomand that saves the session when you quit neovim.
  --- Create a command that lists sessions in a telescope prompt.
  --
  --NOTE: register the VimLeavePre autocmd only
  --after entering a buffer, so empty sessions are not saved.
  vim.api.nvim_create_autocmd("VimLeavePre", {
    once = true,
    group = vim.api.nvim_create_augroup(M.title, { clear = true }),
    callback = function()
      if vim.fn.isdirectory(M.session_dir) == 0 then
        -- NOTE: ensure that the sessions directory exists
        local ok, e = pcall(vim.fn.mkdir, M.session_dir, "p")
        if ok == false then
          vim.notify(
            "Failed to create sessions directory: " .. e,
            vim.log.levels.ERROR,
            {
              title = M.title,
            }
          )
          return
        end
      end

      -- When leaving neovim, save the current session
      -- to the session directory.

      local buffers = vim.api.nvim_list_bufs()
      local removed = 0

      for _, buf in ipairs(buffers) do
        local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
        local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
        -- NOTE: remove some buffers that are not needed
        -- when restoring the session.
        for _, pattern in ipairs(M.ignore_filetype_patterns) do
          if
              buftype:len() > 0
              or filetype:match(pattern)
              or filetype:len() == 0
          then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
            removed = removed + 1
            break
          end
        end
      end

      -- NOTE: if after removing the buffers above, there are no
      -- buffers left, then do not save the session.
      -- This is to avoid saving empty sessions.
      if #buffers - removed <= 0 then
        return
      end

      local name = util.escape_path(vim.fn.getcwd())
      local file = util.path(M.session_dir, name .. ".vim")
      pcall(
        vim.api.nvim_exec,
        "mksession! " .. vim.fn.fnameescape(file),
        true
      )
    end,
  })
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
    a = util.path(M.session_dir, a)
    b = util.path(M.session_dir, b)
    return vim.loop.fs_stat(a).mtime.sec > vim.loop.fs_stat(b).mtime.sec
  end)
  return sessions
end

--- Create a telescope finder for all available sessions.
--- The dinfer displays the session name and the last modified time.
local function session_finder(results)
  local entry_display = require "telescope.pickers.entry_display"
  local finders = require "telescope.finders"

  -- Build a telescope finder for the available sessions
  -- The finder displays the results provided as an argument
  -- to this function. It displays the session name and the
  -- last modified time and the keybinding to delte the session.
  return finders.new_table {
    results = results,
    entry_maker = function(line)
      return {
        value = line,
        ordinal = line,
        display = function(e)
          local time = vim.fn.strftime(
            "%c",
            vim.fn.getftime(util.path(M.session_dir, e.value))
          )

          local displayer = entry_display.create {
            separator = " ",
            items = {
              { width = string.len(time) + 1 },
              { remaining = true },
            },
          }
          -- NOTE: replate % signs with / in the displayed
          -- session name, so it better represents the session's
          -- working directory.
          local value = util.unescape_path(e.value:gsub(".vim$", ""))
          return displayer {
            { time, "Comment" },
            value,
          }
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

  if selection == nil then
    return
  end

  local session_file = util.path(M.session_dir, selection.value)

  if vim.fn.delete(session_file) ~= 0 then
    -- Notify that the session could not be deleted
    vim.notify("Failed to delete session", vim.log.levels.WARN, {
      title = M.title,
    })
  else
    -- Notify that the session was successfully deleted
    -- and refresh the picker with a new finder, so
    -- the removed session is no longer displayed.
    vim.notify("Session deleted", vim.log.levels.INFO, {
      title = M.title,
    })
    -- TODO: maybe this could be done more elegantly
    -- by using a different method that just deletes a row
    picker:refresh(session_finder(get_sessions()), { reset_prompt = true })
  end
end

---Load the session selected in a telescope prompt
local function select_session(prompt_bufnr)
  local action_state = require "telescope.actions.state"
  local actions = require "telescope.actions"

  local selection = action_state.get_selected_entry()
  if selection == nil then
    return
  end
  -- Close the prompt when selecting a session
  actions.close(prompt_bufnr)
  local session_file = util.path(M.session_dir, selection.value)
  -- NOTE: ensure the session file exists
  if vim.fn.filereadable(session_file) == 1 then
    -- if the session file exists, load it
    vim.cmd("silent! source " .. vim.fn.fnameescape(session_file))
  else
    -- Notify that the selected session is no longer available
    vim.notify("Session file is not readable", vim.log.levels.WARN, {
      title = M.title,
    })
  end
end

---List all available sessions in a telescope prompt.
---The sessions may then be selected (loaded) or deleted.
---@param theme table?: Optional telescope theme
function M.list_sessions(theme)
  local pickers = require "telescope.pickers"
  local actions = require "telescope.actions"

  ---NOTE: use ivy theme by default
  theme = theme or require("telescope.themes").get_ivy()

  local sessions = get_sessions()
  if next(sessions) == nil then
    -- NOTE: Do not open the telescope prompt if there are no sessions
    vim.notify("There are no available sessions", vim.log.levels.WARN, {
      title = M.title,
    })
    return
  end

  -- NOTE: build the telescope picker for
  -- displaying the available sessions
  local sessions_picker = pickers.new(theme, {
    prompt_title = M.title,
    results_title = "<CR> - Load session, <C-d> - Delete session",
    selection_strategy = "row",
    finder = session_finder(sessions),
    generic_sorter = require("telescope.sorters").get_fzy_sorter,
    attach_mappings = function(prompt_bufnr, map)
      -- NOTE: load the session under the cursor
      -- when pressing <CR>
      actions.select_default:replace(function()
        select_session(prompt_bufnr)
      end)
      -- NOTE: delete the session under
      -- the cursor when <Ctrl-d> is pressed
      for _, mode in ipairs { "n", "i" } do
        map(mode, "<C-d>", function()
          delete_selected_session(prompt_bufnr)
        end)
      end
      return true
    end,
  })

  sessions_picker:find()
end

return M.init()
