local util = require("util")

---@class FtpluginUtil
---@field filetype string
---@field delay number
local Ftplugin = {}
Ftplugin.__index = Ftplugin

local loaded = {}

---Creates a new filetype plugin. If not filetype
---is provided, the current buffer's filetype is used.
---If no delay is provided, a default delay of 200ms is used.
---
---For example, if you want to override formatter, linter
---or language server in a local config, you may just
---create a new filetype plugin in the local config with
---lower delay and then the default won't be loaded.
---
---@param filetype string?
---@param delay number?
---@return FtpluginUtil
function Ftplugin:new(filetype, delay)
  return setmetatable({
    filetype = type(filetype) == "string" and filetype or vim.bo.filetype,
    delay = type(delay) == "number" and delay or 200,
  }, Ftplugin)
end

---Attaches a formatter to the filetype plugin, if
---no formatter has yet been attached to it.
---
---Passing nil as the formatter will just mark
---the formatter as loaded, without actually
---attaching any formatters.
---
---@param formatter string|function
---@return FtpluginUtil
function Ftplugin:attach_formatter(formatter)
  self:__run(function()
    if self:__loaded({ self.filetype, "formatter" }) then
      return self
    end
    self:__load({ self.filetype, "formatter" })
    util.misc().attach_formatter(formatter, self.filetype)
  end)
  return self
end

---Attaches a language server to the filetype plugin, if
---no language server has yet been attached to it.
---
---Passing nil as the language_server will just mark
---the language_server as loaded, without actually
---attaching any language_servers.
---
---@param language_server string?
---@param opts table?
---@return FtpluginUtil
function Ftplugin:attach_language_server(language_server, opts)
  self:__run(function()
    if self:__loaded({ self.filetype, "language_server" }) then
      return self
    end
    self:__load({ self.filetype, "language_server" })
    if type(language_server) == "string" then
      util.misc().attach_language_server(language_server, opts)
    end
  end)
  return self
end

---Attaches a linter to the filetype plugin, if
---no linter has yet been attached to it.
---
---Passing nil as the linter will just mark
---the linter as loaded, without actually
---attaching any linter.
---
---@param linter string?
---@return FtpluginUtil
function Ftplugin:attach_linter(linter)
  self:__run(function()
    if self:__loaded({ self.filetype, "linter" }) then
      return self
    end
    self:__load({ self.filetype, "linter" })
    if type(linter) == "string" then
      util.misc().attach_linter(linter, self.filetype)
    end
  end)
  return self
end

---Attaches a linter to the filetype plugin, regardless
---of whether or not a linter has already been attached to it.
---(Except if the same linter has already been attached to it.)
---@param linter string
---@return FtpluginUtil
function Ftplugin:attach_additional_linter(linter)
  self:__run(function()
    if
      type(linter) ~= "string"
      or self:__loaded({ self.filetype, "linter", linter })
    then
      return self
    end
    self:__load({ self.filetype, "linter", linter })
    util.require("plugins.null-ls", function(null_ls)
      null_ls.register_linter(linter, self.filetype)
    end)
  end)
  return self
end

---@private
function Ftplugin:__run(f)
  if type(f) ~= "function" then
    return
  end
  vim.defer_fn(function()
    f()
  end, self.delay)
end

---@private
---@param path string[]
function Ftplugin:__loaded(path)
  local l = loaded
  for _, k in ipairs(path) do
    if type(l) ~= "table" or not l[k] then
      return false
    end
    l = l[k]
  end
  return l ~= nil
end

---@private
---@param path string[]
function Ftplugin:__load(path)
  local l = loaded
  for _, k in ipairs(path) do
    if type(l[k]) ~= "table" then
      l[k] = {}
    end
    l = l[k]
  end
end

return Ftplugin
