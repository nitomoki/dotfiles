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
    -- --command はホスト名より前に置く。et 7.1 以降はホスト名より後ろの引数を
    -- すべてリモートコマンドとして扱い、--command ごとシェルに打ち込まれて
    -- command not found で即終了する。-c は ssh の暗号指定に変わったので使えない。
    --
    -- et 7.1 は --command の接続の記録 (平文の passkey を含む) を終了後も
    -- ~/.et/sessions に残し、掃除もしないので、tmux の入口は --no-persist にする。
    -- 作業は tmux に残るので再アタッチは要らない。ただし et --kill が使えなくなり、
    -- クライアントが死ぬと etterminal が残り続けるため、--disconnect-timeout (分) で
    -- 閉じさせる。素のシェルは再アタッチが役に立ち、記録も exit で消えるので付けない。
    launch_menu = {
        { label = "WSL", args = { "/bin/zsh", "-l" } },
        { label = "WSL (tmux)", args = { "/bin/zsh", "-lc", "tmux new -A -s shell" } },
        { label = "Nucbox", args = { "/bin/zsh", "-lc", "et nucbox" } },
        { label = "Nucbox (tmux)", args = { "/bin/zsh", "-lc", "et --no-persist --disconnect-timeout 1440 --command '~/dotfiles/bin/tmux-sessionizer' nucbox" } },
    },
}
