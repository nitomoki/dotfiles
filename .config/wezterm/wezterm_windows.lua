-- Windows 用の環境別設定
-- WezTerm の設定ディレクトリに wezterm_env.lua としてコピーして使用

local wezterm = require "wezterm"

wezterm.on("gui-startup", function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
    window:gui_window():toggle_fullscreen()
end)

-- IME 制御 (動作確認用 / spawn 検証モード):
-- 前段の診断で WSL2 経由なら user-var-changed イベントは発火することが確定。
-- ただし cmd.exe + ">>" リダイレクト経由の追記は走っていなかった。
-- 本番では im-select.exe を引数だけで叩くのでリダイレクト不要。
-- ここでは「外部プロセス起動自体が動いているか」を別経路で見る。
--
-- 痕跡:
--   wezterm-ime-loaded.log     ← config 読込時に追記 (Lua I/O)
--   wezterm-ime-handler.log    ← user-var-changed 発火時に追記 (Lua I/O)
--   wezterm-ime-test.log       ← IME 状態を Lua I/O で直書き (旧 cmd.exe 経路の代替)
--   wezterm-ime-spawn.log      ← spawn したプロセス自身が書く (PowerShell 経由)
--
-- 切り分け:
--   spawn.log が出る           → background_child_process は動いている (本番で im-select.exe を呼べる)
--   spawn.log が出ない         → 外部プロセス起動が完全に死んでいる (権限 / PATH 等を疑う)

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

append_line(home_path "wezterm-ime-loaded.log", "[" .. os.date "%Y-%m-%d %H:%M:%S" .. "] wezterm_windows.lua loaded")
wezterm.log_info "wezterm_windows.lua loaded (IME spawn check mode)"

wezterm.on("user-var-changed", function(_window, _pane, name, value)
    append_line(
        home_path "wezterm-ime-handler.log",
        "[" .. os.date "%Y-%m-%d %H:%M:%S" .. "] event name=" .. tostring(name) .. " value=" .. tostring(value)
    )
    wezterm.log_info("user-var-changed name=" .. tostring(name) .. " value=" .. tostring(value))

    if name ~= "IME" then
        return
    end

    -- (a) IME 状態は Lua I/O で堅実に記録 (本番の運用ログとしてもこのまま使える形)
    append_line(
        home_path "wezterm-ime-test.log",
        "[" .. os.date "%Y-%m-%d %H:%M:%S" .. "] IME=" .. tostring(value)
    )

    -- (b) 外部プロセス起動の単独検証: PowerShell で wezterm-ime-spawn.log に追記させる。
    --     これが書ければ wezterm.background_child_process は動作しており、本番で
     --     im-select.exe をそのまま呼び出せると確定する。
    wezterm.background_child_process {
        "powershell.exe",
        "-NoProfile",
        "-Command",
        "Add-Content -Path \"$env:USERPROFILE\\wezterm-ime-spawn.log\" -Value (\"[\" + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + \"] spawned IME=" .. tostring(value) .. "\")",
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
