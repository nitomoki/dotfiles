-- WSL2 用の環境別設定
-- ~/.config/wezterm/wezterm_env.lua へシンボリックリンクして使用

return {
    default_prog = { "/bin/zsh", "-l" },
    font_size = 9.0,

    launch_menu = {
        { label = "Shell", args = { "/bin/zsh", "-l" } },
        { label = "Shell (tmux)", args = { "/bin/zsh", "-lc", "tmux new" } },
        { label = "Claude (local)", args = { "/bin/zsh", "-lc", "tmux new -A -s claude" } },
        { label = "Claude (Nucbox)", args = { "/bin/zsh", "-lc", "if command -v mosh >/dev/null 2>&1; then mosh nucbox -- tmux new -A -s claude; else autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' nucbox -t 'tmux new -A -s claude'; fi" } },
        { label = "Neovim", args = { "/bin/zsh", "-lc", "tmux new -A -s neovim" } },
    },
}
