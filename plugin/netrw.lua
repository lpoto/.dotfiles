--=============================================================================
-------------------------------------------------------------------------------
--                                                                        NETRW
--=============================================================================
-- Config for vim's default file explorer, also defines it's remappings.
--_____________________________________________________________________________

---Default setup for the default file explorer Netrw
---Set up it's style and remappings.
---Toggle netrw with CTRL-n
vim.g["netrw_browse_split"] = 4
vim.g["netrw_altv"] = 1
vim.g["netrw_liststyle"] = 3
vim.g["netrw_winsize"] = -60

local open_netrw
local close_netrw

---Toggle the netrw explorer with :ToggleNetrw
vim.api.nvim_create_user_command("ToggleNetrw", function()
  if close_netrw() == false then
    open_netrw()
  end
end, {})

---Toggle the netrw explorer with Ctrl + n
--vim.api.nvim_set_keymap("n", "<C-n>", "<cmd>ToggleNetrw<CR>", {
--silent = true,
--})

---Open vertical Netrw
open_netrw = function()
  vim.fn.execute("1wincmd w", true)
  vim.fn.execute("Vexplore", true)
  vim.opt_local.bufhidden = "wipe"
end

---Close Netrw if oppened
---@return boolean: Whether the netrw was successfully closed
close_netrw = function()
  --NOTE: find the netrw buffer if it exists
  local get_ls = vim.tbl_filter(function(b)
    return vim.api.nvim_buf_is_valid(b)
      and vim.api.nvim_buf_is_loaded(b)
      and vim.fn.getbufvar(b, "&filetype") == "netrw"
  end, vim.api.nvim_list_bufs())

  if next(get_ls) == nil then
    --NOTE: there is no oppened netrw buffer
    return false
  end
  --NOTE: a netrw buffer is oppened, wipe it
  local _, netrw_buf = next(get_ls)
  local ok, e = pcall(vim.fn.execute, "bwipeout " .. netrw_buf, true)
  if ok == false then
    vim.notify(e, vim.log.levels.WARN)
    return false
  end
  return true
end
