local wezterm = require "wezterm"

wezterm.on("format-tab-title", function(tab)
    local pane = tab.active_pane
    local proc = pane.foreground_process_name or ""
    local title = pane.title or ""
    -- プロセス名から接続先を判定
    if proc:match "mosh" then
        return "mosh"
    elseif proc:match "ssh" or proc:match "autossh" then
        return "ssh"
    elseif title ~= "" and not title:match "^wslhost" then
        return title
    end
    return "Tab " .. (tab.tab_index + 1)
end)

-- タブバートグル (Alt+b)
local toggle_tab_bar = wezterm.action_callback(function(window)
    local overrides = window:get_config_overrides() or {}
    if overrides.enable_tab_bar == nil then
        overrides.enable_tab_bar = true
    else
        overrides.enable_tab_bar = not overrides.enable_tab_bar
    end
    window:set_config_overrides(overrides)
end)

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
            key = "Enter",
            mods = "ALT",
            action = wezterm.action.ToggleFullScreen,
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
        -- タブバー表示トグル
        {
            key = "b",
            mods = "ALT",
            action = toggle_tab_bar,
        },
    },
    color_scheme = "tokyonight",
    term = "wezterm",

    tab_bar_at_bottom = false,
    enable_tab_bar = false,
    disable_default_key_bindings = true,
    disable_default_mouse_bindings = false,
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
