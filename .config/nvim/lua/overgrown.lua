local M = {}

local function reset()
    vim.api.nvim_command "hi clear"

    if vim.fn.exists "syntax_on" then
        vim.cmd "syntax reset"
    end
    vim.cmd "set termguicolors"
end

function M.setup()
    reset()
    -- stylua: ignore start
    local colors = {
        smoky_black      = "#0C0C0C",
        eerie_black      = "#1A1A1A",
        raisin_black     = "#262626",
        dark_charcoal    = "#303030",
        gray             = "#7E7E7E",
        quick_silver     = "#A5A5A5",
        chinese_silver   = "#CCCCCC",
        anti_flash_white = "#F2F2F2",
        white            = "#FFFFFF",

                  -- c00 = "#111A1F"
                  -- c01 = "#8D7856"
                  -- c02 = "#798362"
                  -- c03 = "#9B9257"
                  -- c04 = "#63768A"
                  -- c05 = "#738C9C"
                  -- c06 = "#6998B3"
                  -- c07 = "#9A9A9A"
                  -- c08 = "#868B8D"
                  -- bk0 = "#3E4B59"
                  -- bk1 = "#151A1E"
                  -- bk2 = "#14191F"
                  -- bk3 = "#2D3640"
                  -- com = "#5A5A5A"
                  -- err = "#810002"
                  -- slc = "#253340"
                  -- dig = "#012800"
                  -- dib = "#340001"
                  -- cdg = "#037500"
                  -- cdy = "#817E00"
                  -- cdr = "#810002"
      ---     palette = {
      -----       base00 = '#112641',
      -----       base01 = '#3a475e',
      -----       base02 = '#606b81',
      -----       base03 = '#8691a7',
      -----       base04 = '#d5dc81',
      -----       base05 = '#e2e98f',
      -----       base06 = '#eff69c',
      -----       base07 = '#fcffaa',
      -----       base08 = '#ffcfa0',
      -----       base09 = '#cc7e46',
      -----       base0A = '#46a436',
      -----       base0B = '#9ff895',
      -----       base0C = '#ca6ecf',
      -----       base0D = '#42f7ff',
      -----       base0E = '#ffc4ff',
      -----       base0F = '#00a5c5',
    }

    local palette = {
        selection = {
            foreground   = colors.smoky_black,
            background   = colors.anti_flash_white,
        },
        background = {
            medium       = colors.smoky_black,
            brighter     = colors.eerie_black,
            brightest    = colors.raisin_black,
        },
        foreground = {
            darkest      = colors.dark_charcoal,
            darker       = colors.gray,
            dimmed       = colors.quick_silver,
            medium       = colors.chinese_silver,
            brighter     = colors.anti_flash_white,
            brightest    = colors.white,
        },
    }

    local groups = {
        normal           = { fg = palette.foreground.medium, bg = palette.background.medium },
        selection        = { fg = palette.selection.foreground, bg = palette.selection.background },

        darkest          = { fg = palette.foreground.darkest },
        darker           = { fg = palette.foreground.darker },
        darker_italic    = { fg = palette.foreground.darker, italic = true },
        dimmed           = { fg = palette.foreground.dimmed },
        dimmed_italic    = { fg = palette.foreground.dimmed, italic = true },
        medium           = { fg = palette.foreground.medium },
        medium_italic    = { fg = palette.foreground.medium, italic = true },
        medium_underline = { fg = palette.foreground.medium, underline = true },
        brighter         = { fg = palette.foreground.brighter },
        brighter_italic  = { fg = palette.foreground.brighter, italic = true },
        brightest        = { fg = palette.foreground.brightest },
        brightest_bold   = { fg = palette.foreground.brightest, bold = true },
    }
    local higlight_groups = {
        Normal                  = groups.normal,

        Bold                    = { bold = true },
        Italic                  = { italic = true },
        Underlined              = { underline = true },

        Visual                  = groups.selection,

        Directory               = groups.brighter,

        IncSearch               = groups.selection,
        Search                  = groups.selection,
        Substitute              = groups.selection,

        MatchParen              = groups.selection,

        ModeMsg                 = groups.brighter,
        MoreMsg                 = groups.brighter,
        NonText                 = { fg = palette.foreground.darkest },

        LineNr                  = groups.dimmed,
        LineNrAbove             = groups.darkest,
        LineNrBelow             = groups.darkest,
        CursorLineNr            = groups.darker,

        StatusLine              = { fg = palette.foreground.medium, bg = palette.background.brighter },
        StatusLineNC            = { fg = palette.foreground.darkest, bg = palette.background.brighter },
        WinSeparator            = { fg = palette.foreground.darkest, bg = palette.background.medium },
        SignColumn              = groups.normal,
        Colorcolumn             = { bg = palette.background.brighter },

        TabLineFill             = { bg = palette.background.brightest },
        TabLine                 = { fg = palette.foreground.dimmed, bg = palette.background.brightest },
        TabLineSel              = { fg = palette.foreground.medium },

        Pmenu                   = { fg = palette.foreground.medium, bg = palette.background.brightest },
        PmenuSel                = groups.selection,
        PmenuSbar               = { bg = palette.background.brightest },

        Conceal                 = groups.darker,
        Title                   = groups.brighter,
        Question                = groups.brighter,
        SpecialKey              = groups.darkest,
        WildMenu                = { fg = palette.foreground.medium, bg = palette.background.brightest },
        Folded                  = { fg = palette.foreground.darker, bg = palette.background.brighter },
        FoldColumn              = { fg = palette.foreground.darkest, bg = palette.background.medium },

        -- Spelling
        SpellBad                = { underline = true },
        SpellLocal              = { underline = true },
        SpellCap                = { underline = true },
        SpellRare               = { underline = true },

        -- Syntax
        Boolean                 = groups.brighter,
        Character               = groups.brighter,
        Comment                 = groups.darker,
        Conditional             = groups.dimmed,
        Constant                = groups.brighter,
        Define                  = groups.darker,
        Delimiter               = groups.darker,
        Float                   = groups.brighter,
        Function                = groups.brighter,
        Identifier              = groups.medium,
        Include                 = groups.darker,
        Keyword                 = groups.dimmed_italic,
        Label                   = groups.darker,
        Number                  = groups.brighter,
        Operator                = groups.darker,
        PreProc                 = groups.darker,
        Repeat                  = groups.darker,
        Special                 = groups.brighter,
        SpecialChar             = groups.brighter,
        Statement               = groups.medium,
        StorageClass            = groups.brighter,
        String                  = groups.brighter_italic,
        Structure               = groups.brighter,
        Tag                     = groups.medium,
        Todo                    = groups.brightest,
        Type                    = groups.brighter,
        Typedef                 = groups.brighter,

        -- TreeSitter
        TSAnnotation            = groups.darker_italic,
        TSAttribute             = groups.darker,
        TSBoolean               = groups.brighter,
        TSCharacter             = groups.brighter,
        TSCharacterSpecial      = groups.brighter,
        TSComment               = groups.darker_italic,
        TSConditional           = groups.medium,
        TSConstant              = groups.brighter,
        TSConstBuiltin          = groups.brighter,
        TSConstMacro            = groups.darker,
        TSConstructor           = groups.brighter,
        TSDebug                 = groups.medium,
        TSDefine                = groups.medium,
        TSError                 = groups.brightest,
        TSException             = groups.brightest,
        TSField                 = groups.medium,
        TSFloat                 = groups.brighter,
        TSFunction              = groups.brighter,
        TSFuncBuiltin           = groups.brighter,
        TSFuncMacro             = groups.brighter,
        TSInclude               = groups.darker,
        TSKeyword               = groups.dimmed_italic,
        TSKeywordFunction       = groups.dimmed_italic,
        TSKeywordOperator       = groups.dimmed_italic,
        TSKeywordReturn         = groups.dimmed_italic,
        TSLabel                 = groups.darker,
        TSMethod                = groups.brighter,
        TSNamespace             = groups.darker,
        TSNone                  = groups.darkest,
        TSNumber                = groups.brighter,
        TSOperator              = groups.darker,
        TSParameter             = groups.medium,
        TSParameterReference    = groups.darker,
        TSPreProc               = groups.darker,
        TSProperty              = groups.medium,
        TSPunctDelimiter        = groups.darker,
        TSPunctBracket          = groups.darker,
        TSPunctSpecial          = groups.darker,
        TSRepeat                = groups.darker,
        TSStorageClass          = groups.medium,
        TSString                = groups.brighter_italic,
        TSStringRegex           = groups.brighter,
        TSStringEscape          = groups.medium,
        TSStringSpecial         = groups.medium,
        TSSymbol                = groups.brighter,
        TSTag                   = groups.medium,
        TSTagAttribute          = groups.darker,
        TSTagDelimiter          = groups.darker,
        TSText                  = groups.medium,
        TSStrong                = { bold = true },
        TSEmphasis              = { italic = true },
        TSUnderline             = { underline = true },
        TSStrike                = { strikethrough = true },
        TSTitle                 = groups.brighter,
        TSLiteral               = groups.brighter,
        TSURI                   = groups.medium_underline,
        TSMath                  = groups.darker,
        TSTextReference         = groups.darker,
        TSEnvironment           = groups.darker,
        TSEnvironmentName       = groups.darker,
        TSNote                  = groups.medium,
        TSWarning               = groups.brighter,
        TSDanger                = groups.brightest,
        TSTodo                  = groups.brightest,
        TSType                  = groups.medium,
        TSTypeBuiltin           = groups.medium,
        TSTypeQualifier         = groups.darker_italic,
        TSTypeDefinition        = groups.medium,
        TSVariable              = groups.medium,
        TSVariableBuiltin       = groups.medium,

        -- nvim-cmp
        CmpItemAbbr              = { palette.foreground.brighter },
        CmpItemAbbrDeprecated    = { palette.foreground.darker },
        CmpItemAbbrMatch         = { palette.foreground.medium, bold = true },
        CmpItemAbbrMatchFuzzy    = { palette.foreground.medium, bold = true },
        CmpItemKind              = { palette.foreground.medium },
        CmpItemMenu              = { palette.foreground.brighter },
        CmpItemKindClass         = { link = 'Type' },
        CmpItemKindColor         = { link = 'Special' },
        CmpItemKindConstant      = { link = 'Constant' },
        CmpItemKindConstructor   = { link = 'Type' },
        CmpItemKindEnum          = { link = 'Structure' },
        CmpItemKindEnumMember    = { link = 'Structure' },
        CmpItemKindEvent         = { link = 'Exception' },
        CmpItemKindField         = { link = 'Structure' },
        CmpItemKindFile          = { link = 'Tag' },
        CmpItemKindFolder        = { link = 'Directory' },
        CmpItemKindFunction      = { link = 'Function' },
        CmpItemKindInterface     = { link = 'Structure' },
        CmpItemKindKeyword       = { link = 'Keyword' },
        CmpItemKindMethod        = { link = 'Function' },
        CmpItemKindModule        = { link = 'Structure' },
        CmpItemKindOperator      = { link = 'Operator' },
        CmpItemKindProperty      = { link = 'Structure' },
        CmpItemKindReference     = { link = 'Tag' },
        CmpItemKindSnippet       = { link = 'Special' },
        CmpItemKindStruct        = { link = 'Structure' },
        CmpItemKindText          = { link = 'Statement' },
        CmpItemKindTypeParameter = { link = 'Type' },
        CmpItemKindUnit          = { link = 'Special' },
        CmpItemKindValue         = { link = 'Identifier' },
        CmpItemKindVariable      = { link = 'Delimiter' },

        -- Diff
        DiffAdd                 = { bg = palette.background.brighter },
        DiffAdded               = { fg = palette.foreground.medium },

        DiffDelete              = { fg = palette.background.brighter, bg = palette.background.brighter },
        DiffRemoved             = { fg = palette.foreground.darker },

        DiffChange              = { bg = palette.background.brighter },
        DiffText                = { fg = palette.background.medium, bg = palette.foreground.darker, bold = true },

        DiffLine                = { fg = palette.foreground.darker },

        -- Telescope
        TelescopeSelectionCaret = { bg = palette.background.brightest },
        TelescopeSelection      = { bg = palette.background.brightest },
        TelescopeMatching       = groups.brightest_bold,

    }
    --stylua: ignore end
    for name, val in pairs(higlight_groups) do
        vim.api.nvim_set_hl(0, name, val)
    end
end

return M
