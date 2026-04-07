-- WSL2 用の環境別設定
-- ~/.config/wezterm/wezterm_env.lua へシンボリックリンクして使用

return {
    default_prog = { "/bin/zsh", "-l" },
    font_size = 9.0,

    ssh_domains = {
        {
            name = "nucbox",
            remote_address = "nucbox:22",
            username = "tomoki",
            multiplexing = "WezTerm",
            local_echo_threshold_ms = 100,
        },
    },

    launch_menu = {
        { label = "Shell", args = { "/bin/zsh", "-l" } },
        { label = "Claude", args = { "/bin/zsh", "-lc", "claude" } },
        { label = "Neovim", args = { "nvim", "--listen", "/tmp/nvimsocket" } },
    },
}
