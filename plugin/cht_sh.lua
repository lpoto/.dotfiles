--=============================================================================
-------------------------------------------------------------------------------
--                                                                       CHT.SH
--=============================================================================
-- https://cht.sh/
-- Open cheat sheet for the provided keywords
--_____________________________________________________________________________

local log = require "util.log"
local mapper = require "util.mapper"

local M = {}

local open_cht_sh

---create Command :Cht <args> that displays cheat sheet in a new tab.
---`curl cht.sh/{args[1]}/{concat{args[i], '+' | i > 1}}\?T `
---Where args' whitespaces are replaced with '+'
mapper.command("Cht", function(o)
  if next(o.fargs) == nil then
    log.warn "Missing argument to :Cht command!"
    return
  end
  local n = table.remove(o.fargs, 1)
  open_cht_sh({ n }, o.fargs)
end, {
  nargs = "*",
})

-------------------------------------------------------------------------------

---Pipe the output of curl cht.sh command
---to a new scratch tab.
---(curl cht.sh/{args1}/{args2}\?T), where args has
---are separated with '+'.
---
---@param args1 table
---@param args2 table
open_cht_sh = function(args1, args2)
  local n1, n2 = table.concat(args1, "+"), table.concat(args2, "+")

  --NOTE: use 'bash' as the default syntax
  local ft = "bash"
  --NOTE: remove trailing and leading '/' from the command
  local cmd = string.gsub(n1 .. "/" .. n2, "/$", ""):gsub("^/", "")

  --NOTE: set name as the command with "/" replaced with "->"
  --so the whole command is displayed as the name
  local name = string.gsub(cmd, "/+", "->")

  --NOTE: use the  word before  the first / as the filetype
  --for syntax, unless there is no / or the word contains '~',
  --then keep using 'bash'
  if string.find(cmd, "/") ~= nil then
    for str in string.gmatch(n1, "([^" .. "%/" .. "]+)") do
      if string.find(str, "~") == nil then
        ft = str
      end
      break
    end
  end
  --NOTE: execute curl externally and pipe the output into
  --a new tab
  local ok, v = pcall(
    vim.fn.execute,
    "noautocmd tabnew | r !curl cht.sh/" .. cmd .. "\\?T"
  )
  --NOTE: make sure it was successful
  if ok == false then
    log.warn(v)
    return
  end
  ok, v = pcall(vim.fn.bufnr)
  if ok == false then
    log.warn(v)
    return
  end
  pcall(vim.api.nvim_buf_set_lines, v, 0, 4, false, {})

  --NOTE: set the buffer so it is scratch, unmodifiable
  --and readonly
  pcall(vim.api.nvim_buf_set_name, v, name)
  pcall(vim.api.nvim_buf_set_option, v, "syntax", ft)
  pcall(vim.api.nvim_buf_set_option, v, "modifiable", false)
  pcall(vim.api.nvim_buf_set_option, v, "bufhidden", "wipe")
  pcall(vim.api.nvim_buf_set_option, v, "readonly", true)
  pcall(vim.api.nvim_buf_set_option, v, "buftype", "nofile")
  pcall(vim.api.nvim_buf_set_option, v, "swapfile", false)
end

return M
