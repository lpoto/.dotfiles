--=============================================================================
-------------------------------------------------------------------------------
--                                                                USER COMMANDS
--=============================================================================

------- Add custom commands for writing and quitting, so there is no annoyance
-------- when misstyping
for _, key in ipairs { "W", "Wq", "WQ", "WqA", "Wqa", "WQa", "WQA" } do
  vim.api.nvim_create_user_command(key, key:lower(), {
    bang = true,
    bar = true,
    complete = "file",
    nargs = "*",
  })
end
for _, key in ipairs { "Q", "Qa", "QA" } do
  vim.api.nvim_create_user_command(key, key:lower(), {
    bang = true,
    bar = true,
  })
end
