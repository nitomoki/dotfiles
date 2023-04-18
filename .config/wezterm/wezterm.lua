local wezterm = require "wezterm"

wezterm.on("gui-startup", function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
    window:gui_window():toggle_fullscreen()
end)

wezterm.on("user-new-window", function(window, pane)
    window:perform_action(wezterm.action.SpawnWindow, pane)
    window:toggle_fullscreen()
end)
-- { key = 'n', mods = 'SUPER', action = act.SpawnWindow },

local res = {
    keys = {
        -- {
        --     key = "n",
        --     mods = "ALT",
        --     action = wezterm.action.SpawnTab "CurrentPaneDomain",
        -- },
        {
            key = "z",
            mods = "ALT",
            action = wezterm.action.SpawnCommandInNewTab {
                args = { "/bin/zsh", "-l" },
                domain = "CurrentPaneDomain",
            },
        },
        {
            key = "h",
            mods = "ALT",
            action = wezterm.action.ActivateTabRelative(-1),
        },
        {
            key = "l",
            mods = "ALT",
            action = wezterm.action.ActivateTabRelative(1),
        },
        {
            key = "q",
            mods = "CTRL",
            action = wezterm.action.SendString "\x11",
        },
        {
            key = "n",
            mods = "ALT",
            action = wezterm.action.SpawnWindow,
        },
        {
            key = "Enter",
            mods = "ALT",
            action = wezterm.action.ToggleFullScreen,
        },
    },
    color_scheme = "tokyonight",
    default_prog = { "/usr/local/bin/nvim", "--listen", "/tmp/nvimsocket" },

    tab_bar_at_bottom = true,
    hide_tab_bar_if_only_one_tab = true,
    disable_default_key_bindings = true,
    disable_default_mouse_bindings = true,

    font_size = 9.0,
}

local status, l = pcall(function()
    return require "wezterm_local"
end)
if status then
    for key, val in pairs(l) do
        res[key] = val
    end
end

return res
