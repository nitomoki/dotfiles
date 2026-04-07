local wezterm = require "wezterm"

local res = {
    keys = {
        {
            key = "z",
            mods = "ALT",
            action = wezterm.action.SpawnTab "CurrentPaneDomain",
        },
        {
            key = "PageUp",
            mods = "CTRL",
            action = wezterm.action.ActivateTabRelative(-1),
        },
        {
            key = "PageDown",
            mods = "CTRL",
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
        {
            key = "v",
            mods = "ALT",
            action = wezterm.action.PasteFrom "Clipboard",
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

    tab_bar_at_bottom = false,
    hide_tab_bar_if_only_one_tab = true,
    disable_default_key_bindings = true,
    disable_default_mouse_bindings = true,
}

-- 環境別設定 (wezterm_wsl2.lua, wezterm_nucbox.lua, wezterm_windows.lua)
-- → シンボリックリンクで wezterm_env.lua として配置
for _, name in ipairs { "wezterm_env", "wezterm_machine" } do
    local ok, overrides = pcall(require, name)
    if ok then
        for key, val in pairs(overrides) do
            res[key] = val
        end
    end
end

return res
