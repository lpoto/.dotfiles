--=============================================================================
-------------------------------------------------------------------------------
--                                                                  COLORSCHEME
--=============================================================================

local M = {
  "projekt0n/github-nvim-theme",
  version = "v0.0.7",
  lazy = false,
}

local function scheme_config()
  return Util.require("github-theme", function(theme)
    theme.setup({
      theme_style = "dark",
      transparent = true,
      function_style = "italic",
    })
    return true
  end)
end

local override
function M.config()
  if not scheme_config() then
    return
  end
  override({
    { "Identifier", { link = "Normal" } },
    { "LineNr", { link = "WinSeparator" } },
    { "@field", { link = "Special" } },
    { "Type", { fg = "#E6BE8A" } },
    { "@type", { link = "Type" } },
    { "StatusLine", { link = "WinSeparator" } },
    { "StatusLineNC", { link = "StatusLine" } },
    { "TabLine", { fg = "#9F9F9F", bg = "NONE" } },
    { "TabLineSel", { link = "Special" } },
    { "TabLineFill", { link = "WinSeparator" } },
    { "Whitespace", { fg = "#292929", bg = "NONE" } },
    { "NonText", { link = "Whitespace" } },
    { "Folded", { bg = "NONE", fg = "#658ABA" } },
    { "NormalFloat", { bg = "NONE" } },
    { "FloatBorder", { link = "WinSeparator" } },
  })
  override({
    { "GitSignsAdd", { fg = "#569166" } },
    { "GitSignsChange", { fg = "#658AbA" } },
    { "GitSignsDelete", { fg = "#A15C62" } },
  })
  override({
    { "TelescopeBorder", { link = "WinSeparator" } },
    { "TelescopeTitle", { link = "TabLineSel" } },
  })
  override({
    { "NoiceFormatLevelDebug", { link = "NoiceFormatLevelInfo" } },
    { "NoiceFormatLevelTrace", { link = "NoiceFormatLevelInfo" } },
    { "NoiceFormatKind", { link = "Type" } },
    { "NoiceFormatEvent", { link = "Type" } },
  })
end

function override(o)
  local errs = {}
  for _, ov in ipairs(o) do
    local ok, err = pcall(vim.api.nvim_set_hl, 0, unpack(ov))
    if not ok then
      table.insert(errs, err)
    end
  end
  if #errs > 0 then
    Util.log(200):warn(table.concat(errs, "\n"))
  end
end

return M
