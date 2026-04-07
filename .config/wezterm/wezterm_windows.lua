-- Windows 用の環境別設定
-- WezTerm の設定ディレクトリに wezterm_env.lua としてシンボリックリンクして使用

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

    ssh_domains = {
        {
            name = "nucbox",
            remote_address = "nucbox:22",
            username = "tomoki",
            multiplexing = "WezTerm",
            local_echo_threshold_ms = 100,
            ssh_option = {
                -- WSL2 の SSH を経由して Nucbox に接続
                proxycommand = "wsl.exe ssh -W %h:%p nucbox",
            },
        },
    },

    launch_menu = {
        { label = "Shell (WSL)", args = { "wsl.exe", "--", "/bin/zsh", "-l" } },
        { label = "Claude (WSL)", args = { "wsl.exe", "--", "/bin/zsh", "-lc", "claude" } },
        { label = "PowerShell", args = { "pwsh.exe" } },
    },
}
