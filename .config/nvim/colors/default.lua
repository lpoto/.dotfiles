--=============================================================================
--                                                               COLORS-DEFAULT
--=============================================================================

local M = {}

function M.init()
  if M.__initialized then return M end
  M.__initialized = true

  M.set_scheme_options()
  M.hl.load()
  return M
end

function M.set_scheme_options()
  local ok, e = pcall(function()
    vim.o.background = "dark"
    vim.o.termguicolors = true
    vim.t_Co = 256
    vim.cmd 'let &t_8f = "\\<Esc>[38;2;%lu;%lu;%lum"'
    vim.cmd 'let &t_8b = "\\<Esc>[48;2;%lu;%lu;%lum"'
  end)
  if not ok then error("Could not set colorscheme options: " .. e) end
end

M.hl = {}

function M.hl.load()
  for _, groups in pairs(M.hl or {}) do
    if type(groups) == "table" then
      for group, attributes in pairs(groups) do
        if type(group) == "string" and type(attributes) == "table" then
          local ok, e = pcall(vim.api.nvim_set_hl, 0, group, attributes)
          if not ok then
            error("Could not set highlight " .. group .. ": " .. e)
          end
        end
      end
    end
  end
end

M.colors = {
  normal = "#c9d1d9",
  variable = "#c9d1d9",
  field = "#c9d1d9",
  parameter = "#b9d7fa",
  abbr = "#9caab8",
  title = "#79b8ff",
  whitespace = "#27292e",
  nonText = "#57677d",
  visual = "#163356",
  separator = "#444c56",
  tabline = "#7f98a3",
  cursorline = "#1b1e24",
  type = "#e6be8a",
  comment = "#687078",
  keyword = "#f97583",
  typeQualifier = "#f97583",
  macro = "#9492f0",
  special = "#79b8ff",
  constant = "#79b8ff",
  string = "#9ecbff",
  symbol = "#eba071",
  func = "#b392f0",
  func_param = "#e1e4e8",
  reference = "#265459",
  tag = "#55c2b7",
  label = "#55c2b7",
  operator = "#94a3b3",
  error = "#f97583",
  warning = "#cca700",
  info = "#75beff",
  hint = "#eeeeb3",
  green = "#7fd488",
  blue = "#78afe3",
  yellow = "#e3c57d",
  red = "#f97583",
  dimmed = {
    blue = "#658aba",
    green = "#569166",
    red = "#a15c62",
  },
}

M.hl.base = {
  Normal = { fg = M.colors.normal, bg = "NONE" },
  NormalNC = { link = "Normal" },
  NormalSB = { link = "Normal" },
  Conceal = { link = "Normal" },

  Field = { fg = M.colors.field },

  Whitespace = { fg = M.colors.whitespace, bg = "NONE" },
  NonText = { fg = M.colors.nonText, bg = "NONE" },
  EndOfBuffer = { link = "Whitespace" },

  Visual = { bg = M.colors.visual },
  VisualNOS = { link = "Visual" },
  MatchParen = { link = "Visual" },
  Search = { link = "Visual" },

  VertSplit = { fg = M.colors.separator, bg = "NONE" },
  WinSeparator = { link = "VertSplit" },

  LineNr = { link = "WinSeparator" },
  SignColumn = { bg = "NONE", fg = M.colors.normal },

  StatusLine = { link = "WinSeparator" },
  StatusLineNC = { link = "StatusLine" },

  TabLine = { fg = M.colors.tabline, bg = "NONE", italic = true },
  TabLineSel = { fg = M.colors.title, bg = "NONE" },
  TabLineFill = { link = "WinSeparator" },

  CursorLine = { bg = M.colors.cursorline },
  CursorLineNr = { italic = true, fg = M.colors.normal },
  CursorLineSign = { link = "CursorLineNr" },
  Folded = { bg = "NONE", fg = M.colors.blue },
  FoldColumn = { link = "Folded" },

  Title = { fg = M.colors.title, bg = "NONE", italic = true },

  FloatTile = { link = "Title" },
  NormalFloat = { link = "Normal" },
  FloatBorder = { link = "WinSeparator" },
  LspInfoBorder = { link = "FloatBorder" },

  Type = { fg = M.colors.type, italic = true },

  Tag = { fg = M.colors.tag },

  Label = { fg = M.colors.label },

  Keyword = { fg = M.colors.keyword },
  Statement = { link = "Keyword" },
  Conditional = { link = "Keyword" },
  Storageclass = { link = "Keyword" },
  PreCondit = { link = "Keyword" },
  Define = { link = "Keyword" },
  Include = { link = "Keyword" },
  Repeat = { link = "Keyword" },
  Exception = { link = "Keyword" },
  Operator = { fg = M.colors.operator },

  PreProc = { fg = M.colors.macro, italic = true },
  Macro = { link = "PreProc" },

  Constant = { fg = M.colors.constant },
  Variable = { fg = M.colors.variable },
  Parameter = { fg = M.colors.parameter },
  Special = { fg = M.colors.special },
  SpecialKey = { link = "Special" },
  Directory = { link = "Special" },

  String = { fg = M.colors.string },
  Character = { fg = M.colors.symbol, italic = true },
  Number = { fg = M.colors.symbol, italic = true },
  Float = { link = "Number" },
  Boolean = { fg = M.colors.symbol, italic = true },

  Comment = { fg = M.colors.comment, italic = true },

  Function = { fg = M.colors.func },

  Identifier = { link = "Normal" },
  Delimiter = { link = "Identifier" },

  Underlined = { underline = true },
  Italic = { italic = true },
  Bold = { bold = true },

  Todo = { fg = M.colors.hint, italic = true, bold = true },

  Pmenu = { link = "Normal" },
  PmenuSel = { link = "Visual" },
  PmenuSbar = { bg = "NONE" },
  PmenuKind = { link = "Constant" },
  PmenuThumb = { bg = M.colors.whitespace },
  PmenuExtra = { link = "Comment" },
}

M.hl.diagnostics = {
  LspReferenceText = { bg = M.colors.reference },
  LspReferenceRead = { link = "LspReferenceText" },
  LspReferenceWrite = { link = "LspReferenceText" },
  LspDiagnosticsDefaultError = { fg = M.colors.error },
  LspDiagnosticsDefaultWarning = { fg = M.colors.warning },
  LspDiagnosticsDefaultInformation = { fg = M.colors.info },
  LspDiagnosticsDefaultHint = { fg = M.colors.hint },
  LspDiagnosticsVirtualTextError = { fg = M.colors.error, italic = true },
  LspDiagnosticsVirtualTextWarning = { fg = M.colors.warning, italic = true },
  LspDiagnosticsVirtualTextInformation = { fg = M.colors.info, italic = true },
  LspDiagnosticsVirtualTextHint = { fg = M.colors.hint, italic = true },
  LspDiagnosticsUnderlineError = { undercurl = true },
  LspDiagnosticsUnderlineWarning = { undercurl = true },
  LspDiagnosticsUnderlineInformation = { undercurl = true },
  LspDiagnosticsUnderlineHint = { undercurl = true },
  LspDiagnosticsError = { link = "LspDiagnosticsDefaultError" },
  LspDiagnosticsWarning = { link = "LspDiagnosticsDefaultWarning" },
  LspDiagnosticsInformation = { link = "LspDiagnosticsDefaultInformation" },
  LspDiagnosticsHint = { link = "LspDiagnosticsDefaultHint" },
  DiagnosticError = { link = "LspDiagnosticsDefaultError" },
  DiagnosticWarn = { link = "LspDiagnosticsDefaultWarning" },
  DiagnosticInfo = { link = "LspDiagnosticsDefaultInformation" },
  DiagnosticHint = { link = "LspDiagnosticsDefaultHint" },
  DiagnosticUnderlineError = { link = "LspDiagnosticsUnderlineError" },
  DiagnosticUnderlineWarn = { link = "LspDiagnosticsUnderlineWarning" },
  DiagnosticUnderlineInfo = { link = "LspDiagnosticsUnderlineInformation" },
  DiagnosticUnderlineHint = { link = "LspDiagnosticsVirtualTextHint" },
  Error = { link = "DiagnosticError" },
  Warning = { link = "DiagnosticWarn" },
  Information = { link = "DiagnosticInfo" },
  ErrorMsg = { link = "DiagnosticError" },
  WarningMsg = { link = "DiagnosticWarn" },
  MoreMsg = { link = "DiagnosticInfo" },
}

M.hl.diff = {
  DiffAdd = { fg = M.colors.green },
  DiffChange = { fg = M.colors.yellow },
  DiffDelete = { fg = M.colors.red },
  DiffText = { fg = M.colors.normal },
  diffAdded = { link = "DiffAdd" },
  diffChanged = { link = "DiffChange" },
  diffRemoved = { link = "DiffDelete" },
  diffOldFile = { fg = M.colors.yellow },
  diffNewFile = { fg = M.colors.blue },
  diffFile = { fg = M.colors.variable },
  diffLine = { fg = M.colors.normal },
  diffIndexLine = { fg = M.colors.symbol },
}

M.hl.treesitter = {
  ["@function"] = { link = "Function" },
  ["@method"] = { link = "Function" },
  ["@function.builtin"] = { link = "Macro" },

  ["@function.macro"] = { link = "Macro" },
  ["@constant.macro"] = { link = "Macro" },
  ["@lsp.type.macro"] = { link = "Macro" },

  ["@constructor"] = { link = "Variable" },
  ["@constructor.lua"] = { link = "Field" },

  ["@note"] = { link = "Todo" },
  ["@warning"] = { link = "Warning" },
  ["@danger"] = { link = "Error" },

  ["@constant"] = { link = "Constant" },
  ["@constant.comment"] = { link = "Keyword" },

  ["@namespace"] = { link = "Constant" },

  ["@include"] = { link = "Include" },
  ["@keyword"] = { link = "Keyword" },
  ["@keyword.function"] = { link = "Keyword" },
  ["@operator"] = { link = "Operator" },
  ["@parameter"] = { fg = M.colors.func_param },
  ["@punctDelimiter"] = { link = "Identifier" },
  ["@punctBracket"] = { link = "Identifier" },
  ["@punctSpecial"] = { link = "Identifier" },
  ["@punctuation"] = { link = "Identifier" },
  ["@string"] = { link = "String" },
  ["@string.regex"] = { link = "Variable" },
  ["@string.escape"] = { link = "Keyword" },
  ["@type"] = { link = "Type" },
  ["@type.builtin"] = { link = "Type" },
  ["@type.qualifier"] = { fg = M.colors.typeQualifier, italic = true },
  ["@lsp.type.modifier"] = { link = "@type.qualifier" },
  ["@lsp.typemod.keyword"] = { link = "Constant" },
  ["@lsp.type.annotation"] = { link = "PreProc" },
  ["@lsp.typemod.class"] = { link = "Type" },
  ["@lsp.mod.importDeclaration"] = { link = "Normal" },
  ["@lsp.typemod.namespace"] = { link = "Normal" },
  ["@lsp.type.namespace"] = { link = "Normal" },

  ["@variable"] = { link = "Variable" },
  ["@variable.builtin"] = { link = "Variable" },
  ["@tag.delimiter"] = { link = "Identifier" },
  ["@text"] = { link = "Normal" },
  ["@text.reference"] = { link = "Keyword" },

  ["@number"] = { link = "Number" },
  ["@float"] = { link = "Float" },

  ["@conditional"] = { link = "Conditional" },
  ["@storageclass"] = { link = "Storageclass" },
  ["@repeat"] = { link = "Repeat" },
  ["@exception"] = { link = "Exception" },

  ["@field"] = { link = "Field" },
  ["@property"] = { link = "Field" },
  ["@lsp.type.property"] = { link = "Field" },

  ["@tag"] = { link = "Tag" },
  ["@label"] = { link = "Label" },
  ["@field.yaml"] = { link = "Label" },
  ["@property.css"] = { link = "Label" },
  ["@property.scss"] = { link = "Label" },
  ["@variable.scss"] = { link = "Keyword" },

  ["@variable.go"] = { link = "Variable" },
  ["@variable.python"] = { link = "Variable" },
  ["@variable.parameter.python"] = { link = "Parameter" },
  ["@variable.member.go"] = { link = "Parameter" },
}

M.hl.telescope = {
  TelescopeBorder = { link = "WinSeparator" },
  TelescopeTitle = { link = "Title" },
  TelescopePromptPrefix = { link = "Constant" },
  TelescopeMatching = { link = "Constant" },
  TelescopeMultiSelection = { fg = M.colors.comment },
  TelescopeSelection = { bg = M.colors.visual },
}

M.hl.gitsigns = {
  GitSignsAdd = { fg = M.colors.dimmed.green },
  GitSignsChange = { fg = M.colors.dimmed.blue },
  GitSignsDelete = { fg = M.colors.dimmed.red },
  GitSignsCurrentLineBlame = { link = "WinSeparator" },
}

M.hl.cmp = {
  BlinkCmpMenu = { link = "NormalFloat" },
  BlinkCmpMenuBorder = { link = "FloatBorder" },
  BlinkCmpDocSeparator = { link = "FloatBorder" },
  BlinkCmpMenuSelection = { link = "PmenuSel" },
  BlinkCmpScrollBarThumb = { link = "PmenuThumb" },
  BlinkCmpDoc = { link = "NormalFloat" },
  BlinkCmpDocBorder = { link = "FloatBorder" },
  BlinkCmpSignatureHelp = { link = "NormalFloat" },
  BlinkCmpSignatureHelpBorder = { link = "FloatBorder" },
  BlinkCmpSignatureHelpActiveParameter = {
    link = "LspSignatureActiveParameter",
  },
  BlinkCmpLabel = { link = "Pmenu" },
  BlinkCmpLabelMatch = { link = "Parameter" },
  BlinkCmpSource = { link = "NonText" },
  BlinkCmpGhostText = { link = "NonText" },
  BlinkCmpDocCursorLine = { link = "CursorLine" },
}

return M.init()
