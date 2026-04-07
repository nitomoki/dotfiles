-- Windows 用の環境別設定
-- WezTerm の設定ディレクトリに wezterm_env.lua としてコピーして使用

local wezterm = require "wezterm"

wezterm.on("gui-startup", function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
    window:gui_window():toggle_fullscreen()
end)

return {
    -- Windows では WSL2 のデフォルトディストロをデフォルトに
    default_domain = "WSL:Ubuntu",

    font_size = 10.0,

    launch_menu = {
        { label = "Shell", args = { "wsl.exe", "--", "/bin/zsh", "-l" } },
        { label = "Claude (WSL)", args = { "wsl.exe", "--", "/bin/zsh", "-lc", "tmux new -A -s claude" } },
        { label = "Claude (Nucbox)", args = { "wsl.exe", "--", "/bin/zsh", "-lc", "autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' nucbox -t 'tmux new -A -s claude'" } },
        { label = "Neovim (WSL)", args = { "wsl.exe", "--", "/bin/zsh", "-lc", "tmux new -A -s neovim" } },
        { label = "PowerShell", args = { "pwsh.exe" } },
    },
}
