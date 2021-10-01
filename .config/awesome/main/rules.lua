
local awful         = require("awful")
local beautiful     = require("beautiful")
local clientkeys = require'keybinds.clientkeys'
local clientbuttons = require'keybinds.clientbuttons'

local M = {}
-- }}}

-- {{{ Rules

-- Rules to apply to new clients (through the "manage" signal).

M.setup = function()
    awful.rules.rules = {
        -- All clients will match this rule.
        {   rule = { },
            properties = { border_width = beautiful.border_width,
                         border_color = beautiful.border_normal,
                         focus = awful.client.focus.filter,
                         raise = true,
                         keys = clientkeys,
                         buttons = clientbuttons,
                         screen = awful.screen.preferred,
                         placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                         size_hints_honor = false
            }
        },
        {   rule = { class = "Vieb" },
            properties = {
                floating = true,
            },
        },
        -- Floating clients.
        { rule_any = {
            instance = {
            },
            class = {
            },
            name = {
            },
            role = {
            },
          }, properties = { floating = true }},

        -- Add titlebars to normal clients and dialogs
        { rule_any = {type = { "normal", "dialog" }
          }, properties = { titlebars_enabled = false }
        },
    }
end

return M
