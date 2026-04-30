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
        { label = "Shell (WSL)", args = { "/bin/zsh", "-l" } },
        { label = "Shell (WSL-tmux)", args = { "/bin/zsh", "-lc", "tmux new -A -s shell" } },
        { label = "Shell (Nucbox)", args = { "/bin/zsh", "-lc", "if command -v mosh >/dev/null 2>&1; then mosh nucbox; else autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' nucbox; fi" } },
        { label = "Shell (Nucbox-tmux)", args = { "/bin/zsh", "-lc", "if command -v mosh >/dev/null 2>&1; then mosh nucbox -- tmux new -A -s shell; else autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' nucbox -t 'tmux new -A -s shell'; fi" } },
        -- ssh 直結 (mosh で OSC 52 クリップボード連携が機能しないときの退避経路)
        { label = "Shell (Nucbox-ssh)", args = { "/bin/zsh", "-lc", "autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' nucbox" } },
        { label = "Shell (Nucbox-ssh-tmux)", args = { "/bin/zsh", "-lc", "autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' nucbox -t 'tmux new -A -s shell'" } },
        { label = "Claude (WSL)", args = { "/bin/zsh", "-lc", "tmux new -A -s claude" } },
        { label = "Claude (Nucbox)", args = { "/bin/zsh", "-lc", "if command -v mosh >/dev/null 2>&1; then mosh nucbox -- tmux new -A -s claude; else autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' nucbox -t 'tmux new -A -s claude'; fi" } },
        { label = "Claude (Nucbox-ssh)", args = { "/bin/zsh", "-lc", "autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' nucbox -t 'tmux new -A -s claude'" } },
        { label = "Neovim (WSL)", args = { "/bin/zsh", "-lc", "tmux new -A -s neovim" } },
    },
}
