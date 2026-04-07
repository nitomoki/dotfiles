-- Windows 用の wezterm_local.lua
-- WezTerm の設定ディレクトリに wezterm_local.lua としてコピーして使用

local wezterm = require "wezterm"

return {
    -- Windows では WSL2 のデフォルトディストロをデフォルトに
    default_domain = "WSL:Ubuntu",

    -- Windows ではフォントサイズを調整
    font_size = 10.0,

    -- WSL ドメインは自動検出されるため設定不要
    -- Nucbox への接続は WSL2 側の wezterm 経由で行う:
    --   wezterm connect nucbox
}
