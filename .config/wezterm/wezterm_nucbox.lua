-- Nucbox 用の環境別設定
-- ~/.config/wezterm/wezterm_env.lua へシンボリックリンクして使用

return {
    default_prog = { "/bin/zsh", "-l" },
    font_size = 9.0,

    -- 各サーバごとに「素のシェル」と「tmux 接続」の 2 種だけを並べる方針。
    -- Nucbox 単体運用なのでローカルのみ。
    launch_menu = {
        { label = "Nucbox", args = { "/bin/zsh", "-l" } },
        { label = "Nucbox (tmux)", args = { "/bin/zsh", "-lc", "tmux new -A -s shell" } },
    },
}
