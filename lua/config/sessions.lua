--=============================================================================
-------------------------------------------------------------------------------
--                                                                     SESSIONS
--[[===========================================================================
Automated session management with telescope.

Commands:
  - :Sessions - Display all available sessions
              (<CR> - load session, <C-d> - delete session)

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
        local ok, _ = pcall(vim.fn.mkdir, M.session_dir, "p")
        if not ok then
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

---Delete the session selected in a telescope prompt
local function delete_selected_session(prompt_bufnr)
  local action_state = require "telescope.actions.state"
  local picker = action_state.get_current_picker(prompt_bufnr)
  local selection = action_state.get_selected_entry()

  if selection == nil then
    return
  end

  local log = util.logger(M.title, "-", "Delete")

  local session_file = util.path(M.session_dir, selection.value)

  if vim.fn.delete(session_file) ~= 0 then
    -- Notify that the session could not be deleted
    log:warn "Failed to delete session"
  else
    log:info "Session deleted"
    -- Filter out the deleted session from the picker
    picker:delete_selection(function(item)
      return selection == item
    end)
  end
end

---Load the session selected in a telescope prompt
local function select_session(prompt_bufnr)
  local action_state = require "telescope.actions.state"
  local actions = require "telescope.actions"
  local log = util.logger(M.title, "-", "Select")

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
    log:warn "Session file is not readable"
  end
end

---List all available sessions in a telescope prompt.
---The sessions may then be selected (loaded) or deleted.
---@param opts table?: Optional telescope picker opts
function M.list_sessions(opts)
  local entry_display = require "telescope.pickers.entry_display"
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  opts = opts or require("telescope.themes").get_ivy()
  opts = vim.tbl_extend("force", {
    prompt_title = M.title,
    selection_strategy = "row",
    cwd = M.session_dir,
    previewer = false,
    entry_maker = function(line)
      local time =
        vim.fn.strftime("%c", vim.fn.getftime(util.path(M.session_dir, line)))
      return {
        value = line,
        ordinal = time .. " " .. line,
        display = function(e)
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
          local value = util.unescape_path(vim.fn.fnamemodify(e.value, ":r"))
          return displayer {
            { time, "Comment" },
            value,
          }
        end,
      }
    end,
    attach_mappings = function(prompt_bufnr, map)
      -- NOTE: load the session under the cursor
      -- when pressing <CR>
      actions.select_default:replace(function()
        select_session(prompt_bufnr)
      end)
      -- NOTE: delete the session under
      -- the cursor when <Ctrl-d> is pressed
      map("n", "<C-d>", function()
        delete_selected_session(prompt_bufnr)
      end)
      map("n", "d", function()
        delete_selected_session(prompt_bufnr)
      end)
      map("i", "<C-d>", function()
        delete_selected_session(prompt_bufnr)
      end)
      return true
    end,
  }, opts)
  require("telescope.builtin").find_files(opts)
  local max_reps = 10
  local f
  f = function(rep)
    -- NOTE: this is a hack to ensure that the session
    -- under the current working directory is selected
    -- when opening the session list.
    -- If it exists...
    if rep >= max_reps then
      return
    end
    vim.defer_fn(function()
      local picker = action_state.get_current_picker(vim.fn.bufnr())
      if picker == nil then
        return
      end
      for k, v in pairs(picker.finder.results) do
        if
          util.unescape_path(vim.fn.fnamemodify(v.value, ":r"))
          == vim.fn.getcwd()
        then
          picker:set_selection(k - 1)
          rep = max_reps
          break
        end
      end
      f(rep + 1)
    end, 10)
  end
  f(0)
end

return M.init()
