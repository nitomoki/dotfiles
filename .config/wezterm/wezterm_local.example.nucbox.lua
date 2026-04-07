-- Nucbox 用の wezterm_local.lua
-- ~/.config/wezterm/wezterm_local.lua としてコピーして使用

return {
    default_prog = { "/bin/zsh", "-l" },
    font_size = 9.0,

    launch_menu = {
        { label = "Shell", args = { "/bin/zsh", "-l" } },
        { label = "Claude", args = { "/bin/zsh", "-lc", "claude" } },
        { label = "Neovim", args = { "nvim", "--listen", "/tmp/nvimsocket" } },
    },
}
