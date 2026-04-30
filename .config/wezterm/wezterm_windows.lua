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
--   初回イベント発火時に WezTerm の log に warn を出すだけで GUI には影響させない。
--
-- 注意:
--   wezterm.run_child_process は内部で yield するため module 評価中
--   (require の途中) に呼ぶと "attempt to yield across a C-call boundary"
--   で require 失敗 → 設定丸ごとロード不能になる。必ずイベント
--   ハンドラ内 (= coroutine 上) で呼び、結果は wezterm.GLOBAL に
--   キャッシュする。
local function find_zenhan()
    if wezterm.GLOBAL.zenhan_path ~= nil then
        return wezterm.GLOBAL.zenhan_path or nil
    end
    local ok, stdout = wezterm.run_child_process { "where.exe", "zenhan.exe" }
    local resolved = nil
    if ok and stdout and stdout ~= "" then
        -- where.exe は \r\n 区切りで複数返す可能性がある。先頭行を採用。
        resolved = stdout:gsub("\r", ""):match "([^\n]+)"
    end
    wezterm.GLOBAL.zenhan_path = resolved or false
    if resolved then
        wezterm.log_info("IME OSC handler: zenhan resolved at " .. resolved)
    else
        wezterm.log_warn "IME OSC handler: zenhan.exe not found on PATH; IME OSC user-var will be ignored"
    end
    return resolved
end

wezterm.on("user-var-changed", function(_window, _pane, name, value)
    if name ~= "IME" then
        return
    end
    local path = find_zenhan()
    if not path then
        return
    end
    -- value は user-var の生文字列 ("0" / "1")。zenhan 第1引数にそのまま渡す。
    wezterm.background_child_process { path, tostring(value) }
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
