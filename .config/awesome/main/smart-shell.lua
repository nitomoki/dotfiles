local awful = require'awful'
local gfs = require'gears.filesystem'
local wibox = require'wibox'
local gears = require'gears'


local ICON = ''

local smart_shell = awful.widget.prompt()

local M = {}

local wb = wibox {
    bg = '#1e252c',
    border_width = 1,
    border_color = '#84bd00',
    max_widget_size = 500,
    ontop = true,
    height = 50,
    width = 250,
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 3)
    end
}

wb:setup {
    {
        layout = wibox.container.margin,
        left = 10,
        smart_shell,
    },
    id = 'left',
    layout = wibox.layout.fixed.horizontal,
}

M.launch = function()
    wb.visible = true

    awful.placement.top(wb, { margins = {top=40}, parent = awful.screen.focused()})
    awful.prompt.run{
        prompt = "<b>$</b> ",
        bg_cursor = '#84bd00',
        textbox = smart_shell.widget,
        exe_callback = function(input_text)
            if not input_text or #input_text == 0 then return end
            awful.spawn(input_text)
        end,
        done_callback = function()
            wb.visible = false
        end
    }
end

return M




