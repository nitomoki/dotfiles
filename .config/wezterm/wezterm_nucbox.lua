-- Nucbox 用の環境別設定
-- ~/.config/wezterm/wezterm_env.lua へシンボリックリンクして使用

return {
    default_prog = { "/bin/zsh", "-l" },
    font_size = 9.0,

    -- 各サーバごとに「素のシェル」と「tmux 接続」の 2 種だけを並べる方針。
    -- Nucbox 単体運用なのでローカルのみ。
    -- tmux 接続は固定セッション (shell) ではなく tmux-sessionizer のピッカーを
    -- 開き、テーマ別セッションを選んで入る。zsh 関数 t の実体だが、
    -- zsh -lc は .zshrc を読まないので関数名では呼べず、PATH も通らないため
    -- フルパスで起動する (~ は zsh が展開する)。
    launch_menu = {
        { label = "Nucbox", args = { "/bin/zsh", "-l" } },
        { label = "Nucbox (tmux)", args = { "/bin/zsh", "-lc", "~/dotfiles/bin/tmux-sessionizer" } },
    },
}
