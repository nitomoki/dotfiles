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

require'lualine'.setup{
    options = {
        theme = 'gruvbox_material'
    },
    tabline = {
        lualine_a = {},
        lualine_b = {fullhalf},
        lualine_c = {'filename'},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    },
}



