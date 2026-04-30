-- Windows 用の環境別設定
-- WezTerm の設定ディレクトリに wezterm_env.lua としてコピーして使用

local wezterm = require "wezterm"

wezterm.on("gui-startup", function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
    window:gui_window():toggle_fullscreen()
end)

-- IME 制御 (動作確認用 / 多重診断モード):
-- リモート/ローカルから OSC 1337 SetUserVar=IME=... を受け取り、
-- 複数経路で痕跡を残して「config 読み込みが効いているか」「ハンドラが発火しているか」
-- 「外部プロセス起動が動いているか」を切り分けられるようにしている。
--
-- テスト方法 (任意のシェルから):
--   printf '\033]1337;SetUserVar=IME=%s\007' "$(printf off | base64)"
--   printf '\033]1337;SetUserVar=IME=%s\007' "$(printf on  | base64)"
--
-- 確認 (PowerShell):
--   Get-Content $env:USERPROFILE\wezterm-ime-test.log         ← 外部プロセス起動の痕跡
--   Get-Content $env:USERPROFILE\wezterm-ime-handler.log      ← ハンドラ発火の痕跡 (Lua I/O 直書き)
--   Get-Content $env:USERPROFILE\wezterm-ime-loaded.log       ← config 読み込み時に必ず1行出る
--   wezterm cli list                                          ← log_info も拾えれば
--
-- どの痕跡が出るかで層別に切り分け：
--   loaded.log すら出ない         → config 自体が読めていない
--   loaded.log だけ出る            → ハンドラが発火していない (OSC 1337 が届いていない)
--   handler.log だけ出る           → ハンドラは動くが background_child_process が動いていない
--   全部出る / ime-test.log も出る → 配線 OK

local function home_path(name)
    return (os.getenv "USERPROFILE" or os.getenv "HOME" or "") .. "\\" .. name
end

local function append_line(path, line)
    local f = io.open(path, "a")
    if f then
        f:write(line .. "\n")
        f:close()
    end
end

-- (1) config が読み込まれた瞬間に必ず1行残す
append_line(home_path "wezterm-ime-loaded.log", "[" .. os.date "%Y-%m-%d %H:%M:%S" .. "] wezterm_windows.lua loaded")
wezterm.log_info "wezterm_windows.lua loaded (IME diag mode)"

wezterm.on("user-var-changed", function(_window, _pane, name, value)
    -- (2) ハンドラに入った時点で全イベントを記録（IME 以外も含めて見える化）
    append_line(
        home_path "wezterm-ime-handler.log",
        "[" .. os.date "%Y-%m-%d %H:%M:%S" .. "] event name=" .. tostring(name) .. " value=" .. tostring(value)
    )
    wezterm.log_info("user-var-changed name=" .. tostring(name) .. " value=" .. tostring(value))

    if name ~= "IME" then
        return
    end

    -- (3) 外部プロセス起動経路: cmd.exe で %USERPROFILE% に追記
    wezterm.background_child_process {
        "cmd.exe",
        "/c",
        "echo [" .. os.date "%Y-%m-%d %H:%M:%S" .. "] IME=" .. value .. " >> %USERPROFILE%\\wezterm-ime-test.log",
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
        -- ssh 直結 (mosh で OSC 52 クリップボード連携が機能しないときの退避経路)
        { label = "Shell (Nucbox-ssh)", args = { "/bin/zsh", "-lc", "autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' nucbox" } },
        { label = "Shell (Nucbox-ssh-tmux)", args = { "/bin/zsh", "-lc", "autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' nucbox -t 'tmux new -A -s shell'" } },
        { label = "Claude (WSL)", args = { "/bin/zsh", "-lc", "tmux new -A -s claude" } },
        { label = "Claude (Nucbox)", args = { "/bin/zsh", "-lc", "if command -v mosh >/dev/null 2>&1; then mosh nucbox -- tmux new -A -s claude; else autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' nucbox -t 'tmux new -A -s claude'; fi" } },
        { label = "Claude (Nucbox-ssh)", args = { "/bin/zsh", "-lc", "autossh -M 0 -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' nucbox -t 'tmux new -A -s claude'" } },
        { label = "Neovim (WSL)", args = { "/bin/zsh", "-lc", "tmux new -A -s neovim" } },
    },
}
