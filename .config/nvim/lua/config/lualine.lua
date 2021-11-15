local M ={}

local jpmode = require'config.japanesemode'
local function fullhalf()
    if jpmode.PLUGIN_JPMODE == nil then
        return [[HALF]]
    end
    if jpmode.PLUGIN_JPMODE_CURRENT() then
        return [[FULL]]
    else
        return [[HALF]]
    end
end

M.setup = function()
    vim.cmd([[set statusline=""]])
    vim.cmd([[set tabline=""]])
    vim.cmd([[redraws]])
    vim.cmd([[redrawt]])
    require'lualine'.setup{
        options = {
            theme = 'gruvbox-material'
        },
        sections = {
            lualine_a = {'mode'},
            --lualine_b = {'branch', 'diff'},
            lualine_b = {},
            lualine_c = {'filename'},
            lualine_x = {'encoding', 'fileformat', 'filetype'},
            lualine_y = {'progress'},
            lualine_z = {'location'},
        },
        tabline = {
            lualine_a = {},
            lualine_b = {fullhalf},
            lualine_c = {'buffers'},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {}
        },
    }
    vim.cmd([[redraws]])
    vim.cmd([[redrawt]])
end

return M


