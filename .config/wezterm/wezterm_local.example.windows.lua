-- Windows 用の wezterm_local.lua
-- WezTerm の設定ディレクトリに wezterm_local.lua としてコピーして使用

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
        { label = "Shell (WSL)", args = { "wsl.exe", "--", "/bin/zsh", "-l" } },
        { label = "Claude (WSL)", args = { "wsl.exe", "--", "/bin/zsh", "-lc", "claude" } },
        { label = "PowerShell", args = { "pwsh.exe" } },
    },
}
