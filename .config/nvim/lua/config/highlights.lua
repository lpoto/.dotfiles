--=============================================================================
--                                                                   HIGHLIGHTS
--[[===========================================================================
Set up custom highlights, as a custom colorscheme.
-----------------------------------------------------------------------------]]
local hl = {}

local colors = {
  normal = '#c9d1d9',
  normal2 = '#b4babf',
  title = '#79b8ff',
  whitespace = '#1f2124',
  visual = '#163356',
  separator = '#444c56',
  tabline = '#7f98a3',
  cursorline = '#1b1e24',
  type = '#e6be8a',
  comment = '#687078',
  keyword = '#f97583',
  macro = '#9492f0',
  variable = '#79b8ff',
  special = '#79b8ff',
  constant = '#79b8ff',
  string = '#9ecbff',
  symbol = '#eba071',
  func = '#b392f0',
  func_param = '#e1e4e8',
  reference = '#265459',
  tag = '#55c2b7',
  operator = '#94a3b3',
  error = '#f97583',
  warning = '#cca700',
  info = '#75beff',
  hint = '#eeeeb3',
  green = '#7fd488',
  blue = '#78afe3',
  yellow = '#e3c57d',
  red = '#f97583',
  dimmed = {
    blue = '#658aba',
    green = '#569166',
    red = '#a15c62',
  },
}

hl.base = {
  Normal = { fg = colors.normal, bg = 'NONE' },
  NormalNC = { link = 'Normal' },
  NormalSB = { link = 'Normal' },
  Conceal = { link = 'Normal' },

  Whitespace = { fg = colors.whitespace, bg = 'NONE' },
  NonText = { link = 'Whitespace' },
  EndOfBuffer = { link = 'Whitespace' },

  Visual = { bg = colors.visual },
  VisualNOS = { link = 'Visual' },
  MatchParen = { link = 'Visual' },
  Search = { link = 'Visual' },

  VertSplit = { fg = colors.separator, bg = 'NONE' },
  WinSeparator = { link = 'VertSplit' },

  LineNr = { link = 'WinSeparator' },
  SignColumn = { bg = 'NONE', fg = colors.normal },

  StatusLine = { link = 'WinSeparator' },
  StatusLineNC = { link = 'StatusLine' },

  TabLine = { fg = colors.tabline, bg = 'NONE', italic = true },
  TabLineSel = { fg = colors.title, bg = 'NONE' },
  TabLineFill = { link = 'WinSeparator' },

  CursorLine = { bg = colors.cursorline },
  CursorLineNr = { italic = true, fg = colors.normal },
  CursorLineSign = { link = 'CursorLineNr' },
  Folded = { bg = 'NONE', fg = colors.blue },
  FoldColumn = { link = 'Folded' },

  Title = { fg = colors.title, bg = 'NONE', italic = true },

  FloatTile = { link = 'Title' },
  NormalFloat = { link = 'Normal' },
  FloatBorder = { link = 'WinSeparator' },
  LspInfoBorder = { link = 'FloatBorder' },

  Type = { fg = colors.type, italic = true },

  Tag = { fg = colors.tag },

  Keyword = { fg = colors.keyword },
  Statement = { link = 'Keyword' },
  Conditional = { link = 'Keyword' },
  PreCondit = { link = 'Keyword' },
  Define = { link = 'Keyword' },
  Include = { link = 'Keyword' },
  Repeat = { link = 'Keyword' },
  Label = { link = 'Keyword' },
  Operator = { fg = colors.operator },

  PreProc = { fg = colors.macro, italic = true },
  Macro = { link = 'PreProc' },

  Constant = { fg = colors.constant },
  Variable = { fg = colors.variable },
  Special = { fg = colors.special },
  SpecialKey = { link = 'Special' },
  Directory = { link = 'Special' },

  String = { fg = colors.string },
  Character = { fg = colors.symbol, italic = true },
  Number = { fg = colors.symbol, italic = true },
  Boolean = { fg = colors.symbol, italic = true },

  Comment = { fg = colors.comment, italic = true },

  Function = { fg = colors.func },

  Identifier = { link = 'Normal' },
  Delimiter = { link = 'Identifier' },

  Underlined = { underline = true },
  Italic = { italic = true },
  Bold = { bold = true },

  Todo = { fg = colors.hint, italic = true, bold = true },

  Pmenu = { link = 'Normal' },
  PmenuSel = { link = 'Visual' },
  PmenuSbar = { bg = 'NONE' },
  PmenuThumb = { bg = colors.whitespace },
}

hl.diagnostics = {
  LspReferenceText = { bg = colors.reference },
  LspReferenceRead = { link = 'LspReferenceText' },
  LspReferenceWrite = { link = 'LspReferenceText' },
  LspDiagnosticsDefaultError = { fg = colors.error },
  LspDiagnosticsDefaultWarning = { fg = colors.warning },
  LspDiagnosticsDefaultInformation = { fg = colors.info },
  LspDiagnosticsDefaultHint = { fg = colors.hint },
  LspDiagnosticsVirtualTextError = { fg = colors.error, italic = true },
  LspDiagnosticsVirtualTextWarning = { fg = colors.warning, italic = true },
  LspDiagnosticsVirtualTextInformation = { fg = colors.info, italic = true },
  LspDiagnosticsVirtualTextHint = { fg = colors.hint, italic = true },
  LspDiagnosticsUnderlineError = { undercurl = true },
  LspDiagnosticsUnderlineWarning = { undercurl = true },
  LspDiagnosticsUnderlineInformation = { undercurl = true },
  LspDiagnosticsUnderlineHint = { undercurl = true },
  LspDiagnosticsError = { link = 'LspDiagnosticsDefaultError' },
  LspDiagnosticsWarning = { link = 'LspDiagnosticsDefaultWarning' },
  LspDiagnosticsInformation = { link = 'LspDiagnosticsDefaultInformation' },
  LspDiagnosticsHint = { link = 'LspDiagnosticsDefaultHint' },
  DiagnosticError = { link = 'LspDiagnosticsDefaultError' },
  DiagnosticWarn = { link = 'LspDiagnosticsDefaultWarning' },
  DiagnosticInfo = { link = 'LspDiagnosticsDefaultInformation' },
  DiagnosticHint = { link = 'LspDiagnosticsDefaultHint' },
  DiagnosticUnderlineError = { link = 'LspDiagnosticsUnderlineError' },
  DiagnosticUnderlineWarn = { link = 'LspDiagnosticsUnderlineWarning' },
  DiagnosticUnderlineInfo = { link = 'LspDiagnosticsUnderlineInformation' },
  DiagnosticUnderlineHint = { link = 'LspDiagnosticsVirtualTextHint' },
  Error = { link = 'DiagnosticError' },
  Warning = { link = 'DiagnosticWarn' },
  Information = { link = 'DiagnosticInfo' },
  ErrorMsg = { link = 'DiagnosticError' },
  WarningMsg = { link = 'DiagnosticWarn' },
  MoreMsg = { link = 'DiagnosticInfo' },
}

hl.diff = {
  DiffAdd = { fg = colors.green },
  DiffChange = { fg = colors.yellow },
  DiffDelete = { fg = colors.red },
  DiffText = { fg = colors.normal },
  diffAdded = { link = 'DiffAdd' },
  diffChanged = { link = 'DiffChange' },
  diffRemoved = { link = 'DiffDelete' },
  diffOldFile = { fg = colors.yellow },
  diffNewFile = { fg = colors.blue },
  diffFile = { fg = colors.variable },
  diffLine = { fg = colors.normal },
  diffIndexLine = { fg = colors.symbol },
}

hl.treesitter = {
  ['@function'] = { link = 'Function' },
  ['@method'] = { link = 'Function' },
  ['@function.builtin'] = { link = 'Macro' },
  ['@property'] = { link = 'Function' },

  ['@function.macro'] = { link = 'Macro' },
  ['@constant.macro'] = { link = 'Macro' },
  ['@lsp.type.macro'] = { link = 'Macro' },

  ['@label'] = { link = 'Variable' },

  ['@constructor'] = { link = 'Variable' },

  ['@note'] = { link = 'Todo' },
  ['@warning'] = { link = 'Warning' },
  ['@danger'] = { link = 'Error' },

  ['@constant'] = { link = 'Constant' },
  ['@constant.comment'] = { link = 'Keyword' },

  ['@field'] = { link = 'Identifier' },
  ['@include'] = { link = 'Include' },
  ['@keyword'] = { link = 'Keyword' },
  ['@keyword.function'] = { link = 'Keyword' },
  ['@namespace'] = { link = 'Identifier' },
  ['@operator'] = { link = 'Operator' },
  ['@parameter'] = { fg = colors.func_param },
  ['@punctDelimiter'] = { link = 'Identifier' },
  ['@punctBracket'] = { link = 'Identifier' },
  ['@punctSpecial'] = { link = 'Identifier' },
  ['@punctuation'] = { link = 'Identifier' },
  ['@string'] = { link = 'String' },
  ['@string.regex'] = { link = 'Variable' },
  ['@string.escape'] = { link = 'Keyword' },
  ['@type'] = { link = 'Type' },
  ['@variable'] = { link = 'Variable' },
  ['@variable.builtin'] = { link = 'Variable' },
  ['@tag'] = { link = 'Tag' },
  ['@tag.delimiter'] = { link = 'Identifier' },
  ['@text'] = { link = 'Normal' },
  ['@text.reference'] = { link = 'Keyword' },

  ['@constant.html'] = { link = 'Tag' },
  ['@field.yaml'] = { link = 'Tag' },
  ['@field.json'] = { link = 'Tag' },

  ['@variable.go'] = { link = 'Identifier' },
}

hl.telescope = {
  TelescopeBorder = { link = 'WinSeparator' },
  TelescopeTitle = { link = 'Title' },
  TelescopePromptPrefix = { link = 'Constant' },
  TelescopeMatching = { link = 'Constant' },
  TelescopeMultiSelection = { fg = colors.comment },
  TelescopeSelection = { bg = colors.visual },
}

hl.gitsigns = {
  GitSignsAdd = { fg = colors.dimmed.green },
  GitSignsChange = { fg = colors.dimmed.blue },
  GitSignsDelete = { fg = colors.dimmed.red },
  GitSignsCurrentLineBlame = { link = 'WinSeparator' },
}

hl.cmp = {
  CmpDocumentation = { link = 'NormalFloat' },
  CmpDocumentationBorder = { link = 'FloatBorder' },
  CmpItemAbbr = { fg = colors.normal2, bg = 'NONE' },
  CmpItemAbbrDeprecated = { fg = colors.comment, strikethrough = true },
  CmpItemAbbrMatch = { fg = colors.variable },
  CmpItemAbbrDefault = { link = 'Normal' },
  CmpItemAbbrMatchFuzzy = { link = 'CmpItemAbbrMatch' },
  CmpItemMenuDefault = { link = 'CmpItemAbbrDefault' },
}

for _, groups in pairs(hl) do
  for group, attributes in pairs(groups) do
    local ok, e = pcall(vim.api.nvim_set_hl, 0, group, attributes)
    if not ok then
      vim.notify(
        'Error setting highlight ' .. group .. ': ' .. e,
        vim.log.levels.ERROR
      )
    end
  end
end
