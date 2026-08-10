-- WSL2 用の環境別設定
-- ~/.config/wezterm/wezterm_env.lua へシンボリックリンクして使用

return {
    default_prog = { "/bin/zsh", "-l" },
    font_size = 9.0,

    -- 各サーバごとに「素のシェル」と「tmux 接続」の 2 種だけを並べる方針。
    -- Nucbox への接続は Eternal Terminal (et) を使用。
    -- Nucbox (tmux) は固定セッション (shell) ではなく tmux-sessionizer の
    -- ピッカーを開き、テーマ別セッションを選んで入る。zsh 関数 t の実体だが、
    -- 関数はリモートの非対話シェルからは呼べず PATH も通らないため、
    -- フルパスで起動する (~ はリモートのシェルが展開する)。
    launch_menu = {
        { label = "WSL", args = { "/bin/zsh", "-l" } },
        { label = "WSL (tmux)", args = { "/bin/zsh", "-lc", "tmux new -A -s shell" } },
        { label = "Nucbox", args = { "/bin/zsh", "-lc", "et nucbox" } },
        { label = "Nucbox (tmux)", args = { "/bin/zsh", "-lc", "et nucbox -c '~/dotfiles/bin/tmux-sessionizer'" } },
    },
}
