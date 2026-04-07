-- WSL2 用の wezterm_local.lua
-- ~/.config/wezterm/wezterm_local.lua としてコピーして使用

local wezterm = require "wezterm"

return {
    ssh_domains = {
        {
            name = "nucbox",
            remote_address = "nucbox:22",
            username = "tomoki",
            multiplexing = "WezTerm",
            local_echo_threshold_ms = 100,
        },
    },

    -- WSL2 ではGUIを使わないため、default_prog をシェルに変更
    default_prog = { "/bin/zsh", "-l" },
}
