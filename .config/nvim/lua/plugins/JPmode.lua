local _, dev = require("utils").local_plugins_path()

-- IME 切替バックエンドのフルパス。
-- PATH 解決を避けて常に dotfiles 管理下のスクリプトを叩くために、
-- $HOME/dotfiles 配置前提でフルパスを直接組む ($HOME のみに依存)。
local wezterm_uservar = vim.fn.expand "~/dotfiles/bin/wezterm-uservar"

local opt = {
    enable = false,
    IME = {
        jp = nil,
        en = nil,
    },
}

-- mac は swim 経路 (WezTerm OSC 経路の対象外)
if vim.fn.has "mac" == 1 then
    local swim = "/usr/local/bin/swim"
    if vim.fn.executable(swim) ~= 1 then
        opt.enable = true
        opt.IME.jp = {
            cmd = swim,
            args = { "use", "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese" },
        }
        opt.IME.en = {
            cmd = swim,
            args = { "use", "com.apple.keylayout.ABC" },
        }
    end
end

-- WezTerm OSC 1337 経路 (WSL2 / Nucbox 共通):
--   wezterm-uservar IME 1/0 を spawn → tmux DCS passthrough → WezTerm が
--   zenhan.exe を background_child_process で叩く。
--   nvim が WezTerm 経由で開かれているなら WSL2 でも Nucbox(et 経由) でも動く。
--   wezterm-uservar が存在しない (= dotfiles 未展開) 環境では何もしない。
if vim.fn.executable(wezterm_uservar) == 1 then
    opt.enable = true
    opt.IME.jp = {
        cmd = wezterm_uservar,
        args = { "IME", "1" },
    }
    opt.IME.en = {
        cmd = wezterm_uservar,
        args = { "IME", "0" },
    }
end

return {
    "nitomoki/JPmode.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    dev = dev,
    lazy = true,
    init = function()
        if not opt.enable then
            return
        end
        -- mac は <C-M-Space>、それ以外 (Linux: WSL2 / Nucbox) は <C-Space>
        local keymap = vim.fn.has "mac" == 1 and "<C-M-Space>" or "<C-Space>"
        vim.keymap.set({ "i", "c" }, keymap, require("JPmode").toggle, { silent = true, noremap = true })
        vim.keymap.set("n", keymap, require("JPmode").off, { silent = true, noremap = true })
    end,
    config = function()
        if not opt.enable then
            return
        end
        require("JPmode").setup(opt)
        vim.api.nvim_create_autocmd("User", { pattern = "TelescopeKeymap", callback = require("JPmode").off })
    end,
}
