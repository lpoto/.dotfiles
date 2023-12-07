--=============================================================================
--                                                          PLUGIN-AUTOCOMMANDS
--=============================================================================
if vim.g.did_acmds or vim.api.nvim_set_var("did_acmds", true) then return end

local group = vim.api.nvim_create_augroup("PluginAutocmmds", { clear = true })

---------------- Set relative number and cursorline only for the active window,
------------------------------------- and disable them when leaving the window.

vim.api.nvim_create_autocmd(
  { "VimEnter", "WinEnter", "BufWinEnter", "TermOpen" },
  {
    group = group,
    callback = function()
      if vim.wo.number then
        if vim.bo.buftype ~= "" then
          vim.wo.number = false
          vim.wo.relativenumber = false
          vim.wo.cursorline = false
          return
        end
        vim.wo.number = true
        vim.wo.relativenumber = true
        vim.wo.cursorline = true
      end
    end,
  }
)
vim.api.nvim_create_autocmd({ "WinLeave" }, {
  group = group,
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
      vim.wo.cursorline = false
    end
  end,
})

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
  local file = vim.fn.stdpath "data" .. "/shada/" .. tail
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
