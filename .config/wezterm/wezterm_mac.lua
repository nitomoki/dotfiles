-- macOS 用の環境別設定
-- ~/.config/wezterm/wezterm_env.lua へシンボリックリンクして使用 (make setup-wezterm-mac)

-- 共通設定は disable_default_key_bindings = true なので、macOS 標準の
-- Cmd 系ショートカットはここで足し直す (extra_keys は wezterm.lua 側で結合される)。
local wezterm = require "wezterm"
local act = wezterm.action

-- 画像貼り付け (Alt+i: Nucbox へ / Alt+Shift+i: Mac ローカルへ)。Windows 版と同じキー。
-- 経路の考え方は bin/wezterm-imgpaste の冒頭を参照。WezTerm.app の PATH には
-- Homebrew が無いので、bash はフルパスで呼ぶ。
local function imgpaste(args)
    return wezterm.action_callback(function(window, pane)
        local argv = { "/bin/bash", wezterm.home_dir .. "/dotfiles/bin/wezterm-imgpaste" }
        for _, a in ipairs(args) do
            table.insert(argv, a)
        end
        local ok, stdout, stderr = wezterm.run_child_process(argv)
        local path = (stdout or ""):gsub("%s+$", "")
        if not ok or path == "" then
            local detail = (stderr or ""):gsub("%s+$", "")
            window:toast_notification(
                "wezterm-imgpaste",
                detail ~= "" and detail or "クリップボードに画像がありません",
                nil,
                4000
            )
            return
        end
        window:perform_action(act.SendString(path), pane)
    end)
end

local config = {
    -- brew の zsh ではなく macOS 標準の /bin/zsh を使う (他環境と揃える)。
    default_prog = { "/bin/zsh", "-l" },
    font = wezterm.font_with_fallback { "HackGen Console NF", "HackGen35 Console NF" },
    font_size = 14.0,

    -- Option キーを Meta (Alt) として送る。共通設定の Alt+z / Alt+s などを効かせるため。
    send_composed_key_when_left_alt_is_pressed = false,
    send_composed_key_when_right_alt_is_pressed = false,

    -- 各サーバごとに「素のシェル」と「tmux 接続」の 2 種だけを並べる方針 (wsl2 と同じ)。
    launch_menu = {
        { label = "Mac", args = { "/bin/zsh", "-l" } },
        { label = "Mac (tmux)", args = { "/bin/zsh", "-lc", "tmux-sessionizer" } },
        { label = "Nucbox", args = { "/bin/zsh", "-lc", "mosh nucbox" } },
        { label = "Nucbox (tmux)", args = { "/bin/zsh", "-lc", "mosh nucbox -- tmux-sessionizer" } },
    },

    extra_keys = {
        { key = "c", mods = "SUPER", action = act.CopyTo "Clipboard" },
        { key = "v", mods = "SUPER", action = act.PasteFrom "Clipboard" },
        { key = "t", mods = "SUPER", action = act.SpawnTab "CurrentPaneDomain" },
        { key = "w", mods = "SUPER", action = act.CloseCurrentTab { confirm = true } },
        { key = "n", mods = "SUPER", action = act.SpawnWindow },
        { key = "q", mods = "SUPER", action = act.QuitApplication },
        { key = "h", mods = "SUPER", action = act.HideApplication },
        { key = "=", mods = "SUPER", action = act.IncreaseFontSize },
        { key = "-", mods = "SUPER", action = act.DecreaseFontSize },
        { key = "0", mods = "SUPER", action = act.ResetFontSize },

        -- タブ移動。共通の Ctrl+PageUp/PageDown は Mac のキーボードに PageUp が無く
        -- 押せないので、macOS 標準 (Safari / Terminal) と同じ Cmd+Shift+[ / ] を足す。
        -- SHIFT 併用時は WezTerm 既定バインドと同じくシフト後の文字 ("{" / "}") で書く。
        { key = "{", mods = "SUPER|SHIFT", action = act.ActivateTabRelative(-1) },
        { key = "}", mods = "SUPER|SHIFT", action = act.ActivateTabRelative(1) },

        { key = "i", mods = "ALT", action = imgpaste {} },
        { key = "I", mods = "ALT|SHIFT", action = imgpaste { "--local" } },
    },
}

-- Cmd+1〜9 で n 番目のタブへ（macOS 標準と同じ）。
for i = 1, 9 do
    table.insert(config.extra_keys, { key = tostring(i), mods = "SUPER", action = act.ActivateTab(i - 1) })
end

return config
