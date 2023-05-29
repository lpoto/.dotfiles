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
local M = {
  dev = true,
  dir = vim.fn.expand "<sfile>",
  event = "VeryLazy",
}

local title = "Sessions"
local session_dir = Util.path(vim.fn.stdpath "data", "sessions")
local ignore_filetype_patterns = {
  "git.*",
  "qf",
  "help",
  "Telecope.*",
  "lazy",
  "null-ls.*",
  "Lsp.*",
  "mason",
  "noice",
  "Diffview.*",
}
local list_sessions

function M.config()
  vim.api.nvim_create_user_command("Sessions", function()
    list_sessions()
  end, {})

  vim.keymap.set("n", "<leader>s", "<cmd>Sessions<CR>")
  --- Create an autocomand that saves the session when you quit neovim.
  --- Create a command that lists sessions in a telescope prompt.
  --
  --NOTE: register the VimLeavePre autocmd only
  --after entering a buffer, so empty sessions are not saved.
  vim.api.nvim_create_autocmd("VimLeavePre", {
    once = true,
    group = vim.api.nvim_create_augroup(title, { clear = true }),
    callback = function()
      -- When leaving neovim, save the current session
      -- to the session directory.
      if vim.fn.isdirectory(session_dir) == 0 then
        -- NOTE: ensure that the sessions directory exists
        local ok, _ = pcall(vim.fn.mkdir, session_dir, "p")
        if not ok then
          return
        end
      end

      -- NOTE: delete all arguments from the argument list
      -- before saving the session.
      -- This is necessary, as files opened with unception
      -- are added to the argument list, and we do not want
      -- to save them.
      vim.api.nvim_exec("%argdelete", true)

      -- NOTE: iterate open buffers and delete those that
      -- are not valid, or are not files, or are files
      -- with ignored filetypes.
      local buffers = vim.api.nvim_list_bufs()
      local removed = 0

      local check_buffer = function(buf)
        if
          not vim.api.nvim_buf_is_valid(buf)
          or not vim.api.nvim_buf_is_loaded(buf)
        then
          return false
        end
        local filetype = vim.api.nvim_buf_get_option(buf, "filetype") or ""
        local buftype = vim.api.nvim_buf_get_option(buf, "buftype") or ""
        if buftype:len() > 0 or filetype:len() == 0 then
          return false
        end
        for _, pattern in ipairs(ignore_filetype_patterns) do
          if filetype:match(pattern) then
            return false
          end
        end
        return true
      end

      for _, buf in ipairs(buffers) do
        if not check_buffer(buf) then
          pcall(vim.api.nvim_buf_delete, buf, { force = true })
          removed = removed + 1
        end
      end

      -- NOTE: if after removing the buffers above, there are no
      -- buffers left, then do not save the session.
      -- This is to avoid saving empty sessions.
      if #buffers - removed <= 0 then
        return
      end

      local name = Util.escape_path(vim.fn.getcwd())
      local file = Util.path(session_dir, name .. ".vim")
      pcall(
        vim.api.nvim_exec,
        "mksession! " .. vim.fn.fnameescape(file),
        true
      )
    end,
  })
end

---Load the session selected in a telescope prompt
local function select_session(prompt_bufnr)
  Util.require(
    { "telescope.actions", "telescope.actions.state" },
    function(actions, action_state)
      local selection = action_state.get_selected_entry()
      if selection == nil then
        return
      end

      -- Close the prompt when selecting a session
      actions.close(prompt_bufnr)
      local session_file = Util.path(session_dir, selection.value)
      -- NOTE: ensure the session file exists
      if vim.fn.filereadable(session_file) == 1 then
        -- if the session file exists, load it
        vim.defer_fn(function()
          vim.api.nvim_exec(
            "source " .. vim.fn.fnameescape(session_file),
            true
          )
        end, 10)
      else
        -- Notify that the selected session is no longer available
        Util.log():warn "Session no longer available"
      end
    end
  )
end

---Delete the session selected in a telescope prompt
local function delete_selected_session(prompt_bufnr)
  Util.require("telescope.actions.state", function(action_state)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local selection = action_state.get_selected_entry()

    if selection == nil then
      return
    end

    local session_file = Util.path(session_dir, selection.value)

    if vim.fn.delete(session_file) ~= 0 then
      Util.log():warn "Failed to delete session"
    else
      Util.log():info "Session deleted"
      -- Filter out the deleted session from the picker
      picker:delete_selection(function(item)
        return selection == item
      end)
    end
  end)
end

---List all available sessions in a telescope prompt.
---The sessions may then be selected (loaded) or deleted.
---@param opts table?: Optional telescope picker opts
function list_sessions(opts)
  Util.require({
    "telescope.actions",
    "telescope.actions.state",
    "telescope.pickers.entry_display",
    "telescope.builtin",
  }, function(actions, action_state, entry_display, builtin)
    opts = opts or require("telescope.themes").get_ivy()
    opts = vim.tbl_extend("force", {
      prompt_title = title,
      selection_strategy = "row",
      cwd = session_dir,
      previewer = false,
      entry_maker = function(line)
        local time =
          vim.fn.strftime("%c", vim.fn.getftime(Util.path(session_dir, line)))
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
            local value =
              Util.unescape_path(vim.fn.fnamemodify(e.value, ":r"))
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
    builtin.find_files(opts)
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
            Util.unescape_path(vim.fn.fnamemodify(v.value, ":r"))
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
  end)
end

return M
