-- Windows 用の環境別設定
-- WezTerm の設定ディレクトリに wezterm_env.lua としてコピーして使用

local wezterm = require "wezterm"

wezterm.on("gui-startup", function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
    window:gui_window():toggle_fullscreen()
end)

-- IME 制御 (本番):
--   OSC 1337 SetUserVar=IME=<0|1> を受けて zenhan.exe を spawn し、
--   フォーカス先の IME open/close を切り替える。
--     value=1 → zenhan 1 (IME ON / 全角)
--     value=0 → zenhan 0 (IME OFF / 半角)
--
-- フォールバック:
--   zenhan.exe が PATH に無ければ何もしない (handler は登録するが no-op)。
--   起動時に WezTerm の log に warn を出すだけで GUI には影響させない。
local function find_zenhan()
    local ok, stdout = wezterm.run_child_process { "where.exe", "zenhan.exe" }
    if not ok or not stdout or stdout == "" then
        return nil
    end
    -- where.exe は \r\n 区切りで複数返す可能性がある。先頭行を採用。
    return (stdout:gsub("\r", ""):match "([^\n]+)")
end

local zenhan_path = find_zenhan()
if zenhan_path then
    wezterm.log_info("IME OSC handler: zenhan resolved at " .. zenhan_path)
else
    wezterm.log_warn "IME OSC handler: zenhan.exe not found on PATH; IME OSC user-var will be ignored"
end

wezterm.on("user-var-changed", function(_window, _pane, name, value)
    if name ~= "IME" then
        return
    end
    if not zenhan_path then
        return
    end
    -- value は user-var の生文字列 ("0" / "1")。zenhan 第1引数にそのまま渡す。
    wezterm.background_child_process { zenhan_path, tostring(value) }
end)

return {
    -- Windows では WSL2 のデフォルトディストロをデフォルトに
    default_domain = "WSL:Ubuntu",

    font_size = 10.0,

    -- 各サーバごとに「素のシェル」と「tmux 接続」の 2 種だけを並べる方針。
    -- Nucbox への接続は Eternal Terminal (et) を使用。
    launch_menu = {
        { label = "WSL", args = { "/bin/zsh", "-l" } },
        { label = "WSL (tmux)", args = { "/bin/zsh", "-lc", "tmux new -A -s shell" } },
        { label = "Nucbox", args = { "/bin/zsh", "-lc", "et nucbox" } },
        { label = "Nucbox (tmux)", args = { "/bin/zsh", "-lc", "et nucbox -c 'tmux new -A -s shell'" } },
    },
}
