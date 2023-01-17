--=============================================================================
-------------------------------------------------------------------------------
--                                                              TOGGLE TERMINAL
--=============================================================================

local M = {}

M.term_buf = nil

function M.open_win(max_w, max_h, buf)
  local scale = 0.4

  local w = math.min(math.max(20, math.floor(max_w * scale)), max_w / 2)
  if w > 100 then
    w = 100
  end

  local winnr = vim.api.nvim_open_win(buf, true, {
    anchor = "NE",
    row = 0,
    col = max_w,
    height = max_h,
    title = "Terminal",
    noautocmd = true,
    focusable = true,
    relative = "editor",
    style = "minimal",
    width = w,
    border = { "│", " ", "", "", "", " ", "│", "│" },
  })
  return winnr
end

function M.create_buf()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
  return buf
end

function M.open()
  if not M.term_buf or not vim.api.nvim_buf_is_valid(M.term_buf) then
    M.term_buf = M.create_buf()
  end
  if not M.term_buf or not vim.api.nvim_buf_is_valid(M.term_buf) then
    return
  end
  local winid = vim.fn.bufwinid(M.term_buf)
  if winid and winid ~= -1 and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_close(winid, false)
    return
  end
  winid = M.open_win(vim.o.columns, vim.o.lines, M.term_buf)
  vim.api.nvim_win_set_option(
    winid,
    "winhl",
    "FloatBorder:Normal,NormalFloat:Normal,NormalNC:Normal"
  )
  vim.api.nvim_buf_call(M.term_buf, function()
    vim.api.nvim_exec("term", false)
  end)
end

return M.open
