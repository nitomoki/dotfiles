local wezterm = require "wezterm"
local mux = wezterm.mux
local act = wezterm.action
local l = require "wezterm_local"

wezterm.on("gui-startup", function(cmd)
    local _, _, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

local res = {
    keys = {
        {
            key = "n",
            mods = "ALT",
            action = act.SpawnTab "CurrentPaneDomain",
        },
        {
            key = "z",
            mods = "ALT",
            action = act.SpawnCommandInNewTab {
                args = { "/bin/zsh", "-l" },
                domain = "CurrentPaneDomain",
            },
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
    colors = {
        background = "#0c0c0c",
    },
    default_prog = { "/usr/local/bin/nvim", "-l" },

    tab_bar_at_bottom = true,
    hide_tab_bar_if_only_one_tab = true,
}

for key, val in pairs(l) do
    res[key] = val
end

return res
