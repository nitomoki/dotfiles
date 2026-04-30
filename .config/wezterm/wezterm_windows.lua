-- Windows 用の環境別設定
-- WezTerm の設定ディレクトリに wezterm_env.lua としてコピーして使用

local wezterm = require "wezterm"

wezterm.on("gui-startup", function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
    window:gui_window():toggle_fullscreen()
end)

-- IME 制御 (動作確認用): リモート/ローカルから OSC 1337 SetUserVar=IME=... を受け取り、
-- まずは Windows 標準の cmd.exe でログファイルに追記するだけにしてある。
-- 配線が確認できたら im-select.exe 等の実際の IME 切替コマンドに差し替える。
--
-- テスト方法 (任意のシェルから):
--   printf '\033]1337;SetUserVar=IME=%s\007' "$(printf off | base64)"
--   printf '\033]1337;SetUserVar=IME=%s\007' "$(printf on  | base64)"
-- 確認:
--   Windows 側で  type %TEMP%\wezterm-ime-test.log
wezterm.on("user-var-changed", function(_window, _pane, name, value)
    if name ~= "IME" then
        return
    end
    wezterm.background_child_process {
        "cmd.exe",
        "/c",
        "echo [" .. os.date "%Y-%m-%d %H:%M:%S" .. "] IME=" .. value .. " >> %TEMP%\\wezterm-ime-test.log",
    }
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
        { label = "Claude (WSL)", args = { "/bin/zsh", "-lc", "tmux new -A -s claude" } },
        { label = "Claude (Nucbox)", args = { "/bin/zsh", "-lc", "if command -v mosh >/dev/null 2>&1; then mosh nucbox -- tmux new -A -s claude; else autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' nucbox -t 'tmux new -A -s claude'; fi" } },
        { label = "Neovim (WSL)", args = { "/bin/zsh", "-lc", "tmux new -A -s neovim" } },
    },
}
