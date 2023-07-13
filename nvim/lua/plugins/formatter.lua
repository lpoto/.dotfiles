--=============================================================================
-------------------------------------------------------------------------------
--                                                               FORMATTER-NVIM
--[[===========================================================================
https://github.com/mhartington/formatter.nvim

Keymaps:
  - "<leader>f"  - format current buffer, in visual mode format selected text
-----------------------------------------------------------------------------]]
local M = {
  "mhartington/formatter.nvim",
}

local format

M.keys = {
  {
    "<leader>f",
    function()
      format()
    end,
    mode = "n",
  },
  {
    "<leader>f",
    function()
      format(true)
    end,
    mode = "v",
  },
}

function M.config()
  Util.require(
    { "formatter", "formatter.filetypes.any" },
    function(formatter, any)
      formatter.setup({
        logging = true,
        log_level = vim.log.levels.INFO,
        ["*"] = {
          any.remove_trailing_whitespace,
        },
      })
    end
  )
end

local formatters_to_add = {}

---Override the util's default attach formatter function.
---This will attach the formatter lazily. It will only be attached when trying
---to format a buffer of the matching filetype for the first time.
---
---@param cfg string|function
---@param filetype string
---@param additional_args table?
---@diagnostic disable-next-line: duplicate-set-field
Util.misc().attach_formatter = function(cfg, filetype, additional_args)
  if type(filetype) ~= "string" then
    Util.log():warn("Invalid filetype for formatter:", filetype)
    return
  end
  local attach = function()
    Util.require(
      { "formatter", "formatter.filetypes." .. filetype, "formatter.config" },
      function(formatter, ft, config)
        local f = type(cfg) == "string" and ft[cfg] or cfg
        if type(f) ~= "function" then
          Util.log():warn("Invalid formatter for", filetype)
          return
        end
        local opts = config.values or {}
        if type(opts.filetype) ~= "table" then
          opts.filetype = {}
        end
        if type(opts.filetype[filetype]) ~= "table" then
          opts.filetype[filetype] = {}
        end
        if additional_args ~= nil then
          local old_f = f
          f = function(...)
            local o = old_f(...)
            if type(o) == "table" then
              o.args = vim.tbl_extend("force", o.args or {}, additional_args)
            end
            return o
          end
        end

        table.insert(opts.filetype[filetype], f)
        formatter.setup(opts)
        if type(cfg) ~= "string" then
          cfg = "<custom>"
        end
        Util.log():info("Attached formatter for " .. filetype .. ":", cfg)
      end
    )
  end
  if type(formatters_to_add[filetype]) ~= "table" then
    formatters_to_add[filetype] = {}
  end
  table.insert(formatters_to_add[filetype], attach)
end

local function attach_formatters()
  local filetype = vim.api.nvim_buf_get_option(0, "filetype")
  if type(formatters_to_add[filetype]) ~= "table" then
    return
  end
  local to_add = formatters_to_add[filetype]
  formatters_to_add[filetype] = nil
  for _, f in ipairs(to_add) do
    f()
  end
end

function format(visual)
  attach_formatters()

  Util.require("formatter.format", function(fmt)
    local s = 1
    local e = vim.api.nvim_buf_line_count(0)
    if visual then
      -- Leave visual mode
      local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
      vim.api.nvim_feedkeys(esc, "x", false)

      s = vim.api.nvim_buf_get_mark(0, "<")[1]
      e = vim.api.nvim_buf_get_mark(0, ">")[1]
    end
    fmt.format("", "", s, e)
  end)
end

return M
