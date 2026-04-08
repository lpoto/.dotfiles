--=============================================================================
--                                                         DEFAULT AUTOCOMMANDS
--=============================================================================

local group = vim.api.nvim_create_augroup("PluginAutocmmds", { clear = true })

---------------- Set relative number and cursorline only for the active window,
------------------------------------- and disable them when leaving the window.

vim.api.nvim_create_autocmd(
  { "WinEnter" },
  {
    group = group,
    callback = function()
      local buftype = vim.bo.buftype
      if buftype ~= "" and buftype ~= "terminal" then return end
      local cur_win = vim.api.nvim_get_current_win()
      local winids = vim.api.nvim_list_wins()
      for _, id in ipairs(winids) do
        local buf = vim.api.nvim_win_get_buf(id)
        buftype = vim.bo[buf].buftype
        if buftype == "" or buftype == "terminal" then
          local config = vim.api.nvim_win_get_config(id)
          if config.relative == "" then
            if id == cur_win then
              if vim.wo[id].number then
                vim.wo[id].relativenumber = true
              end
              vim.wo[id].cursorline = true
            else
              if vim.wo[id].number then
                vim.wo[id].relativenumber = false
              end
              vim.wo[id].cursorline = false
            end
          end
        end
      end
    end,
  }
)

-------------- Set showmode true in empty buftypes and false in other buftypes.

vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  callback = function()
    if vim.bo.buftype ~= "" then
      vim.opt.showmode = false
    else
      vim.opt.showmode = true
    end
  end,
})

--------------------------------------------------------- Highlight yanked text

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    local ok, hl = pcall(require, "vim.highlight")
    if ok then
      hl.on_yank {
        higroup = "IncSearch",
        timeout = 35,
      }
    end
  end,
})

----------------------------------- Set multispace lischars based on shiftwidth

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  group = group,
  callback = function()
    vim.schedule(function()
      local sw = vim.o.shiftwidth
      local s = "·"
      if sw > 1 then s = "┊" .. string.rep(" ", sw - 1) end
      vim.opt_local.listchars:append {
        multispace = " · ",
        leadmultispace = s,
        tab = "┊ ",
      }
    end)
  end,
})

------------------------------------------------------------------------- Shada
-- Store different shada files based on current working directory

local function shada_autocmd(write, read)
  if write then pcall(vim.api.nvim_exec2, "wshada!", {}) end
  local tail = ((vim.fn.expand "%:p:h") .. ".shada"):gsub("/", "%%")
  local file = vim.fn.stdpath "state" .. "/shada/" .. tail
  vim.opt.shada = {
    "!",
    "'100",
    "<50",
    "s10",
    "h",
    "n" .. file,
  }
  if read then pcall(vim.api.nvim_exec2, "rshada!", {}) end
end
vim.api.nvim_create_autocmd("DirChanged", {
  group = group,
  callback = function()
    vim.schedule(function() shada_autocmd(true, true) end)
  end,
})
shada_autocmd(false, false)

-------------------------------------------------------------- Messages command
-- Add :Messages command that works same as g<

vim.api.nvim_create_user_command("Messages", function()
  vim.cmd "normal! g<"
end, {})
