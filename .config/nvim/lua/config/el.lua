local builtin = require'el.builtin'
local sections = require'el.sections'

local c = require'components'

local highlights = {
    red_fg = c.extract_hl({
          bg = { StatusLine   = 'bg' },
          fg = { ErrorMsg     = 'fg' },
          gui = "bold",
    }),
    green_fg = c.extract_hl({
          bg = { StatusLine   = 'bg' },
          fg = { Green        = 'fg' },
          gui = "bold",
    }),
    yellow_fg = c.extract_hl({
          bg = { StatusLine   = 'bg' },
          fg = { WarningMsg   = 'fg' },
          gui = "bold",
    }),
    blue_fg = c.extract_hl({
          bg = { StatusLine   = 'bg' },
          fg = { Blue         = 'fg' },
          gui = "bold",
    }),
}

local modes = {
            n      = {'Normal', 'N',   { highlights.green_fg } },
            niI    = {'Normal', 'N',   { highlights.green_fg } },
            niR    = {'Normal', 'N',   { highlights.green_fg } },
            niV    = {'Normal', 'N',   { highlights.green_fg } },
            no     = {'N·OpPd', '?',   { highlights.green_fg } },
            v      = {'Visual', 'V',   { highlights.blue_fg } },
            V      = {'V·Line', 'Vl',  { highlights.blue_fg } },
            [''] = {'V·Blck', 'Vb',  { highlights.blue_fg } },
            s      = {'Select', 'S',   { 'Search' } },
            S      = {'S·Line', 'Sl',  { 'Search' } },
            [''] = {'S·Block', 'Sb', { 'Search' } },
            i      = {'Insert', 'I',   { highlights.red_fg } },
            ic     = {'ICompl', 'Ic',  { highlights.red_fg } },
            R      = {'Rplace', 'R',   { 'WarningMsg', 'IncSearch' } },
            Rv     = {'VRplce', 'Rv',  { 'WarningMsg', 'IncSearch' } },
            c      = {'Cmmand', 'C',   { highlights.yellow_fg } },
            cv     = {'Vim Ex', 'E',   },
            ce     = {'Ex (r)', 'E',   },
            r      = {'Prompt', 'P',   },
            rm     = {'More  ', 'M',   },
            ['r?'] = {'Cnfirm', 'Cn',  },
            ['!']  = {'Shell ', 'S',   { highlights.yellow_fg } },
            t      = {'Term  ', 'T',   { highlights.yellow_fg } },
          }

local components = {
    { c.mode { modes = modes, fmt = "%s %s ", icon = " ", hl_icon_only = false } },
    { c.git_branch { fmt = " %s %s ", icon = "", hl=highlights.blue_fg } },
    { c.git_changes_all {
        fmt = "%s",
        delim = " ",
        icon_insert = '+',
        icon_change = '~',
        icon_delete = '-',
        hl_insert = highlights.green_fg,
        hl_change = highlights.yellow_fg,
        hl_delete = highlights.red_fg
        }
    },
    { " | " },
    { c.file_icon { fmt = "%s ", hl_icon = false } },
    { builtin.shortened_file },
    { sections.collapse_builtin{builtin.modified_flag,} },
    { sections.split , required = true },
    { c.diagnostics {
        fmt = "[%s]",
        lsp = true,
        hl_err = highlights.red_fg,
        hl_warn = highlights.yellow_fg,
        hl_info = highlights.green_fg,
        hl_hint = highlights.blue_fg
        }
    },
    { c.git_changes_buf {
        fmt = "[%s]",
        delim = " ",
        icon_insert = '+',
        icon_change = '~',
        icon_delete = '-',
        hl_insert = highlights.green_fg,
        hl_change = highlights.yellow_fg,
        hl_delete = highlights.red_fg
        }
    },
    { sections.collapse_builtin{
            "[",
            builtin.help_list,
            builtin.readonly_list,
            "]",
        }
    },
    { builtin.filetype },
}

local add_item = function(result, item, is_inactive)
    if is_inactive and not item.reaquired then
        return
    end
    table.insert(result, item)
end

local generator = function(window, buffer)
    local is_inactive = vim.o.laststatus ~= 3 and window.win_id ~= vim.api.nvim_get_current_win()
    if not is_inactive then
        for _, ft in ipairs({
        'packer',
        }) do
            if vim.bo[buffer.bufnr].ft == ft then
                is_inactive = true
            end
        end
    end
    local result = {}
    for _, item in ipairs(components) do
        add_item(result, item, is_inactive)
    end
    return result
end


require'el'.setup{
    generator = generator
}
