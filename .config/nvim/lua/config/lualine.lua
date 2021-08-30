local function fullhalf()
    if PLUGIN_JPMODE == nil then
        return [[HALF]]
    end
    if PLUGIN_JPMODE_CURRENT() then
        return [[FULL]]
    else
        return [[HALF]]
    end
end

require'lualine'.setup{
    options = {
        theme = 'molokai'
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



