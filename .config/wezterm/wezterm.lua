local wezterm = require "wezterm"
local mux = wezterm.mux
local act = wezterm.action

wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

return {
    keys = {
        {
            key = "t",
            mods = "ALT",
            action = act.SpawnTab "CurrentPaneDomain",
        },
        {
            key = "h",
            mods = "ALT",
            action = act.ActivateTabRelative(-1),
        },
        {
            key = "l",
            mods = "ALT",
            action = act.ActivateTabRelative(1),
        },
    },
    default_prog = { "/usr/local/bin/nvim", "-l" },

    tab_bar_at_bottom = true,
    hide_tab_bar_if_only_one_tab = true,
    window_background_opacity = 0.75,
}
