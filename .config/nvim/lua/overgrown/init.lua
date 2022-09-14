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

        darkest_green    = "#40331A",
        medium_green     = "#A3A653",
        bright_green     = "#D5D96C",
        brightest_green  = "#D9DBB5",
        emerald_green    = "#BDD9A9",

        crimson_red      = "#370F26",
        azuki_red        = "#371F2D",
        ash_red          = "#383135",
        waring_red       = "#BF3617",

        crimson_pink     = "#9A477C",
        ash_pink         = "#B0819F",

        medium_brown     = "#A3713F",
        bright_brown     = "#AB973C",

    }

    local palette = {
        selection = {
            foreground   = colors.darkest_green,
            background   = colors.brightest_green,
        },
        background = {
            medium       = colors.smoky_black,
            brighter     = colors.eerie_black,
            brightest    = colors.raisin_black,
            green = {
                dark     = colors.darkest_green,
            },
            red   = {
                darkest  = colors.crimson_red,
                darker   = colors.azuki_red,
                medium   = colors.ash_red,
            },
        },
        foreground = {
            darkest      = colors.dark_charcoal,
            darker       = colors.gray,
            dimmed       = colors.quick_silver,
            medium       = colors.chinese_silver,
            brighter     = colors.anti_flash_white,
            brightest    = colors.white,
            warning      = colors.waring_red,
            green = {
                medium   = colors.medium_green,
                bright   = colors.bright_green,
                brightest = colors.brightest_green,
                emerald  = colors.emerald_green,
            },
            red   = {
                medium   = colors.crimson_pink,
                bright   = colors.ash_pink,
            },
            brown = {
                medium   = colors.medium_brown,
                bright   = colors.bright_brown,
            },
        },
    }

    local groups = {
        normal            = { fg = palette.foreground.medium, bg = palette.background.medium },
        selection         = { fg = palette.selection.foreground, bg = palette.selection.background },

        darkest           = { fg = palette.foreground.darkest },
        darker            = { fg = palette.foreground.darker },
        darker_italic     = { fg = palette.foreground.darker, italic = true },
        dimmed            = { fg = palette.foreground.dimmed },
        dimmed_italic     = { fg = palette.foreground.dimmed, italic = true },
        medium            = { fg = palette.foreground.medium },
        medium_italic     = { fg = palette.foreground.medium, italic = true },
        medium_underline  = { fg = palette.foreground.medium, underline = true },
        brighter          = { fg = palette.foreground.brighter },
        brighter_italic   = { fg = palette.foreground.brighter, italic = true },
        brightest         = { fg = palette.foreground.brightest },
        brightest_bold    = { fg = palette.foreground.brightest, bold = true },

        warning           = { fg = palette.foreground.warning },

        green = {
            medium           = { fg = palette.foreground.green.medium },
            medium_italic    = { fg = palette.foreground.green.medium, italic = true },
            bright           = { fg = palette.foreground.green.bright },
            bright_italic    = { fg = palette.foreground.green.bright, italic = true },
            brightest        = { fg = palette.foreground.green.brightest },
            brightest_italic = { fg = palette.foreground.green.brightest, italic = true },
            emerald          = { fg = palette.foreground.green.emerald },
            emerald_italic   = { fg = palette.foreground.green.emerald, italic = true },
        },
        red   = {
            medium        = { fg = palette.foreground.red.medium },
            medium_italic = { fg = palette.foreground.red.medium, italic = true },
            bright        = { fg = palette.foreground.red.bright },
            bright_italic = { fg = palette.foreground.red.bright, italic = true },
        },
        brown = {
            medium        = { fg = palette.foreground.brown.medium },
            medium_italic = { fg = palette.foreground.brown.medium, italic = true },
            bright        = { fg = palette.foreground.brown.bright },
            bright_italic = { fg = palette.foreground.brown.bright, italic = true },
        },

    }
    local higlight_groups = {

        Normal                  = groups.normal,

        Bold                    = { bold = true },
        Italic                  = { italic = true },
        Underlined              = { underline = true },

        Visual                  = groups.selection,

        Directory               = groups.green.bright,

        IncSearch               = groups.selection,
        Search                  = groups.selection,
        Substitute              = groups.selection,

        MatchParen              = groups.selection,

        ModeMsg                 = groups.green.brightest,
        MoreMsg                 = groups.green.brightest,
        NonText                 = { fg = palette.foreground.darkest },

        LineNr                  = groups.green.emerald,
        LineNrAbove             = groups.green.medium,
        LineNrBelow             = groups.green.medium,
        CursorLine              = { bg = colors.eerie_black}, -- TODO
        CursorLineNr            = groups.green.emerald,

        StatusLine              = { fg = palette.foreground.green.bright, bg = palette.background.green.dark },
        StatusLineNC            = { fg = palette.foreground.green.emerald, bg = palette.background.brightest },
        WinSeparator            = { fg = palette.foreground.green.medium, bg = groups.normal.bg },
        SignColumn              = groups.normal,
        Colorcolumn             = { bg = palette.background.green.medium },

        TabLineFill             = { bg = palette.background.brightest },
        TabLine                 = { fg = palette.foreground.red.bright, bg = palette.background.brightest },
        TabLineSel              = { fg = palette.foreground.green.emerald },

        Pmenu                   = { fg = palette.foreground.green.brightest, bg = palette.background.brighter },
        PmenuSel                = groups.selection,
        -- PmenuSbar               = { bg = palette.background.brightest },

        Conceal                 = groups.green.brightest,
        Title                   = groups.green.bright,
        Question                = groups.green.bright,
        SpecialKey              = groups.red.bright,
        WildMenu                = { fg = palette.foreground.green.bright, bg = groups.normal.bg },
        Folded                  = { fg = palette.foreground.green.medium, bg = palette.background.brightest },
        FoldColumn              = { fg = palette.foreground.green.bright, bg = palette.background.red.medium },

        -- Spelling
        SpellBad                = { underline = true },
        SpellLocal              = { underline = true },
        SpellCap                = { underline = true },
        SpellRare               = { underline = true },

        -- Syntax
        Constant                = groups.green.emerald,
        String                  = groups.red.bright_italic,
        Character               = groups.green.emerald,
        Number                  = groups.green.brightest,
        Boolean                 = groups.red.bright_italic,
        Float                   = groups.green.emerald,

        Identifier              = groups.green.emerald,
        Function                = groups.green.brightest,

        Statement               = groups.green.bright,
        Conditional             = groups.green.emerald,
        Repeat                  = groups.green.emerald,
        Label                   = groups.brown.bright_italic,
        Operator                = groups.red.bright,
        Keyword                 = groups.brown.medium_italic,
        Exception               = groups.warning,

        PreProc                 = groups.green.emerald,
        Include                 = groups.brown.medium_italic,
        Define                  = groups.brown.medium,
        Macro                   = groups.green.emerald,
        PreCondit               = groups.green.bright,

        Type                    = groups.green.medium_italic,
        StorageClass            = groups.green.emerald,
        Structure               = groups.green.emerald,
        Typedef                 = groups.brown.bright,

        Special                 = groups.green.emerald,
        SpecialChar             = groups.green.emerald_italic,
        Tag                     = groups.green.emerald,
        Delimiter               = groups.brown.medium,
        SpecialComment          = groups.darker_italic,
        Debug                   = groups.darker_italic,

        Comment                 = groups.darker,

        WarningMsg              = groups.warning,

        Todo                    = groups.warning,

        -- TreeSitter
        TSAnnotation            = groups.darker_italic,
        TSAttribute             = groups.darker,
        TSBoolean               = groups.red.bright_italic,
        TSCharacter             = groups.green.emerald,
        TSCharacterSpecial      = groups.green.emerald_italic,
        TSComment               = groups.darker_italic,
        TSConditional           = groups.green.emerald,
        TSConstant              = groups.green.emerald,
        TSConstBuiltin          = groups.green.emerald_italic,
        TSConstMacro            = groups.green.emerald_italic,
        TSConstructor           = groups.green.emerald,
        TSDebug                 = groups.medium,
        TSDefine                = groups.brown.medium,
        TSError                 = groups.warning,
        TSException             = groups.warning,
        TSField                 = groups.green.brightest,
        TSFloat                 = groups.green.emerald,
        TSFunction              = groups.green.brightest,
        TSFuncBuiltin           = groups.green.emerald,
        TSFuncMacro             = groups.green.emerald,
        TSInclude               = groups.brown.medium_italic,
        TSKeyword               = groups.brown.medium_italic,
        TSKeywordFunction       = groups.red.bright_italic,
        TSKeywordOperator       = groups.brown.medium_italic,
        TSKeywordReturn         = groups.red.bright_italic,
        TSLabel                 = groups.brown.bright_italic,
        TSMethod                = groups.green.brightest,
        TSNamespace             = groups.green.emerald,
        TSNone                  = groups.darkest,
        TSNumber                = groups.green.medium_italic,
        TSOperator              = groups.red.bright,
        TSParameter             = groups.green.bright,
        TSParameterReference    = groups.green.bright_italic,
        TSPreProc               = groups.green.emerald,
        TSProperty              = groups.green.emerald,
        TSPunctDelimiter        = groups.brown.medium,
        TSPunctBracket          = groups.green.emerald,
        TSPunctSpecial          = groups.brown.medium,
        TSRepeat                = groups.green.emerald,
        TSStorageClass          = groups.green.emerald,
        TSString                = groups.red.bright_italic,
        TSStringRegex           = groups.red.bright_italic,
        TSStringEscape          = groups.red.bright_italic,
        TSStringSpecial         = groups.red.bright_italic,
        TSSymbol                = groups.brighter,
        TSTag                   = groups.green.emerald,
        TSTagAttribute          = groups.green.bright,
        TSTagDelimiter          = groups.green.bright,
        TSText                  = groups.green.brightest,
        TSStrong                = { bold = true },
        TSEmphasis              = { italic = true },
        TSUnderline             = { underline = true },
        TSStrike                = { strikethrough = true },
        TSTitle                 = groups.red.bright,
        TSLiteral               = groups.brighter,
        TSURI                   = groups.red.bright_italic,
        TSMath                  = groups.green.emerald,
        TSTextReference         = groups.green.brightest_italic,
        TSEnvironment           = groups.brown.medium,
        TSEnvironmentName       = groups.brown.medium_italic,
        TSNote                  = groups.green.brightest,
        TSWarning               = { link = "WarningMsg" },
        TSDanger                = groups.warning,
        TSTodo                  = groups.warning,
        TSType                  = groups.green.medium_italic,
        TSTypeBuiltin           = groups.green.medium_italic,
        TSTypeQualifier         = groups.green.medium_italic,
        TSTypeDefinition        = groups.brown.bright,
        TSVariable              = groups.green.bright,
        TSVariableBuiltin       = groups.green.bright,

        -- nvim-cmp
        CmpItemAbbr              = { fg = palette.foreground.brighter },
        CmpItemAbbrDeprecated    = { fg = palette.foreground.darker },
        CmpItemAbbrMatch         = { fg = palette.foreground.medium, bold = true },
        CmpItemAbbrMatchFuzzy    = { fg = palette.foreground.medium, bold = true },
        CmpItemKind              = { fg = palette.foreground.medium },
        CmpItemMenu              = { fg = palette.foreground.brighter },
        CmpItemKindClass         = { link = 'TSType' },
        CmpItemKindColor         = { link = 'Special' },
        CmpItemKindConstant      = { link = 'TSConstant' },
        CmpItemKindConstructor   = { link = 'TSConstructor' },
        CmpItemKindEnum          = { link = 'Structure' },
        CmpItemKindEnumMember    = { link = 'Structure' },
        CmpItemKindEvent         = { link = 'TSException' },
        CmpItemKindField         = { link = 'Structure' },
        CmpItemKindFile          = { link = 'TSTag' },
        CmpItemKindFolder        = { link = 'Directory' },
        CmpItemKindFunction      = { link = 'TSFunction' },
        CmpItemKindInterface     = { link = 'Structure' },
        CmpItemKindKeyword       = { link = 'TSKeyword' },
        CmpItemKindMethod        = { link = 'TSFunction' },
        CmpItemKindModule        = { link = 'Structure' },
        CmpItemKindOperator      = { link = 'TSOperator' },
        CmpItemKindProperty      = { link = 'Structure' },
        CmpItemKindReference     = { link = 'TSTag' },
        CmpItemKindSnippet       = { link = 'Special' },
        CmpItemKindStruct        = { link = 'Structure' },
        CmpItemKindText          = { link = 'Statement' },
        CmpItemKindTypeParameter = { link = 'TSType' },
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
        if val == "string" then
            vim.api.nvim_set_hl(0, name, { link = val })
        end
        vim.api.nvim_set_hl(0, name, val)
    end
end

return M
