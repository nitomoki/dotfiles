local gears = require'gears'
local awful = require'awful'
-- local naughty = require'naughty'
-- local hotkeys_popup = require("awful.hotkeys_popup")
-- local lain          = require("lain")
-- local smart_shell = require'main.smart-shell'
local mytable       = awful.util.table or gears.table -- 4.{0,1} compatibility
local var = require'main.variables'

-- local altkey       = var.altkey
local modkey       = var.modkey
-- local terminal     = var.terminal
-- local cycle_prev   = true
-- local browser      = "librewolf"

local M = {}

M = mytable.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

return M
