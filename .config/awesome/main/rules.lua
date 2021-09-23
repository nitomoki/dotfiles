
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

        -- Floating clients.
        { rule_any = {
            instance = {
                "DTA",  -- Firefox addon DownThemAll.
                "copyq",  -- Includes session name in class.
                "pinentry",
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Tor Browser",
                "Wpa_gui",
                "veromix",
                "xtightvncviewer",
            },
            name = {
                "Event Tester",  -- xev.
            },
            role = {
                "AlarmWindow",  -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
            },
          }, properties = { floating = true }},

        -- Add titlebars to normal clients and dialogs
        { rule_any = {type = { "normal", "dialog" }
          }, properties = { titlebars_enabled = false }
        },
    }
end

return M
