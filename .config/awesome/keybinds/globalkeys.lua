local gears = require'gears'
local awful = require'awful'
local naughty = require'naughty'
local hotkeys_popup = require("awful.hotkeys_popup")
-- local beautiful     = require("beautiful")
local lain          = require("lain")
local smart_shell = require'main.smart-shell'
local mytable       = awful.util.table or gears.table -- 4.{0,1} compatibility
local var = require'main.variables'

local altkey       = var.altkey
local modkey       = var.modkey
local terminal     = var.terminal
local cycle_prev   = true
local browser      = var.browser

local M = {}

-- }}}

-- {{{ Key bindings

M = mytable.join(
    -- Destroy all notifications
    awful.key({ "Control",           }, "space", function() naughty.destroy_all_notifications() end,
              {description = "destroy all notifications", group = "hotkeys"}),
    -- Take a screenshot
    -- https://github.com/lcpz/dots/blob/master/bin/screenshot
    -- awful.key({ altkey }, "p", function() os.execute("screenshot") end,
    --           {description = "take a screenshot", group = "hotkeys"}),

    -- X screen locker
    --awful.key({ altkey, "Control" }, "l", function () os.execute(scrlocker) end,
    --          {description = "lock screen", group = "hotkeys"}),

    -- Show help
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),

    -- Tag browsing
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    -- Non-empty tag browsing
    awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end,
              {description = "view  previous nonempty", group = "tag"}),
    awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end,
              {description = "view  previous nonempty", group = "tag"}),

    -- Default client focus
    awful.key({ altkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ altkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- By-direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus down", group = "client"}),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.global_bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus up", group = "client"}),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus left", group = "client"}),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus right", group = "client"}),

    -- Menu
    -- awful.key({ modkey,           }, "w", function () awful.util.mymainmenu:show() end,
    --           {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            if cycle_prev then
                awful.client.focus.history.previous()
            else
                awful.client.focus.byidx(-1)
            end
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "cycle with previous/go back", group = "client"}),

    -- Show/hide wibox
    --awful.key({ modkey }, "b", function ()
    --        for s in screen do
    --            s.mywibox.visible = not s.mywibox.visible
    --            if s.mybottomwibox then
    --                s.mybottomwibox.visible = not s.mybottomwibox.visible
    --            end
    --        end
    --    end,
    --    {description = "toggle wibox", group = "awesome"}),

    -- On-the-fly useless gaps change
    -- awful.key({ altkey, "Control" }, "+", function () lain.util.useless_gaps_resize(1) end,
    --           {description = "increment useless gaps", group = "tag"}),
    -- awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end,
    --           {description = "decrement useless gaps", group = "tag"}),

    -- Dynamic tagging
    --awful.key({ modkey, "Shift" }, "n", function () lain.util.add_tag() end,
    --          {description = "add new tag", group = "tag"}),
    --awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag() end,
    --          {description = "rename tag", group = "tag"}),
    --awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(-1) end,
    --          {description = "move tag to the left", group = "tag"}),
    --awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(1) end,
    --          {description = "move tag to the right", group = "tag"}),
    --awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end,
    --          {description = "delete tag", group = "tag"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey, altkey    }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, altkey    }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    -- awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
    --           {description = "select next", group = "layout"}),
    -- awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
    --           {description = "select previous", group = "layout"}),
    awful.key(
            {modkey,},
            "u",
            function()
                local c = client.focus
                naughty.notify {
                    preset = naughty.config.presets.normal,
                    title = "TEST",
                    text = c.name,
                }
            end,
            {description = "test", group = " TEST" }
        ),

    awful.key({ modkey, "Control" }, "n", function ()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            c:emit_signal("request::activate", "key.unminimize", {raise = true})
        end
    end, {description = "restore minimized", group = "client"}),

    -- Dropdown application
    -- awful.key({ modkey, }, "z", function () awful.screen.focused().quake:toggle() end,
    --           {description = "dropdown application", group = "launcher"}),


    -- Copy primary to clipboard (terminals to gtk)
    awful.key({ modkey }, "c", function () awful.spawn.with_shell("xsel | xsel -i -b") end,
              {description = "copy terminal to gtk", group = "hotkeys"}),
    -- Copy clipboard to primary (gtk to terminals)
    awful.key({ modkey }, "v", function () awful.spawn.with_shell("xsel -b | xsel") end,
              {description = "copy gtk to terminal", group = "hotkeys"}),

    -- User programs
    awful.key({ modkey }, "q", function () awful.spawn(browser) end,
              {description = "run browser", group = "launcher"}),

    awful.key({ modkey }, "r", smart_shell.launch,
              {description = "run prompt", group = "launcher"})
)

return M
