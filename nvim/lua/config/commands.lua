--=============================================================================
-------------------------------------------------------------------------------
--                                                                USER COMMANDS
--=============================================================================

------- Add custom commands for writing and quitting, so there is no annoyance
-------- when misstyping
for _, key in ipairs({ "W", "Wq", "WQ", "WqA", "Wqa", "WQa", "WQA" }) do
  vim.api.nvim_create_user_command(key, key:lower(), {
    bang = true,
    bar = true,
    complete = "file",
    nargs = "*",
  })
end
for _, key in ipairs({ "Q", "Qa", "QA" }) do
  vim.api.nvim_create_user_command(key, key:lower(), {
    bang = true,
    bar = true,
  })
end

------------------------------------------------ Toggle quickfix with :Quickfix
vim.api.nvim_create_user_command("Quickfix", function(opts)
  local enter = vim.tbl_contains(opts.fargs or {}, "enter")
  local open_only = vim.tbl_contains(opts.fargs or {}, "owpen")
  if
    #vim.tbl_filter(
      function(winid)
        return vim.api.nvim_buf_get_option(
          vim.api.nvim_win_get_buf(winid),
          "buftype"
        ) == "quickfix"
      end,
      vim.api.nvim_list_wins()
    ) > 0
  then
    if open_only ~= true then vim.api.nvim_exec2("cclose", {}) end
  else
    local winid = vim.api.nvim_get_current_win()
    vim.api.nvim_exec2("noautocmd keepjumps copen", {})
    if
      #vim.tbl_filter(
        function(l) return #l > 0 end,
        vim.api.nvim_buf_get_lines(0, 0, -1, false)
      ) == 0
    then
      vim.api.nvim_exec2("cclose", {})
      vim.notify(
        "There is nothing to display in the quickfix window",
        vim.log.levels.WARN,
        { title = "Quickfix" }
      )
    end
    if enter ~= true then vim.fn.win_gotoid(winid) end
  end
end, {
  nargs = "*",
  complete = function() return { "toggle", "open" } end,
})
