local wezterm = require "wezterm"

local res = {
    keys = {
        {
            key = "z",
            mods = "ALT",
            action = wezterm.action.SpawnTab "CurrentPaneDomain",
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
        -- mux ドメインへの接続/切断
        {
            key = "a",
            mods = "ALT",
            action = wezterm.action.ShowLauncherArgs { flags = "DOMAINS" },
        },
        -- ランチャーメニュー（launch_menu の項目を選択）
        {
            key = "s",
            mods = "ALT",
            action = wezterm.action.ShowLauncherArgs { flags = "LAUNCH_MENU_ITEMS" },
        },
    },
    color_scheme = "tokyonight",
    term = "wezterm",

    tab_bar_at_bottom = true,
    hide_tab_bar_if_only_one_tab = true,
    disable_default_key_bindings = true,
    disable_default_mouse_bindings = true,
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
