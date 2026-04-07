-- Nucbox 用の環境別設定
-- ~/.config/wezterm/wezterm_env.lua へシンボリックリンクして使用

return {
    default_prog = { "/bin/zsh", "-l" },
    font_size = 9.0,

    launch_menu = {
        { label = "Shell", args = { "/bin/zsh", "-l" } },
        { label = "Claude", args = { "/bin/zsh", "-lc", "tmux new -A -s claude" } },
        { label = "Neovim", args = { "/bin/zsh", "-lc", "tmux new -A -s neovim" } },
    },
}
