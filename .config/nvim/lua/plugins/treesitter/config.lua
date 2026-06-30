-- nvim-treesitter は main ブランチ(完全リライト版)へ移行済み。
-- 旧 require("nvim-treesitter.configs").setup{ ensure_installed/highlight/indent }
-- API は廃止されたため、次の構成へ置き換える:
--   * パーサ管理      … require("nvim-treesitter").setup{} / .install{}
--   * highlight       … Neovim ビルトインの vim.treesitter.start()
--   * indent (実験的) … vim.bo.indentexpr = require'nvim-treesitter'.indentexpr()
local ts = require("nvim-treesitter")

-- 既定値で動くため setup{} は必須ではないが、明示しておく。
ts.setup {}

-- 旧 ensure_installed = "all" 相当。全パーサ(329)を非同期インストールする(導入済みは no-op)。
-- main は parser を tree-sitter CLI でビルドするため初回は重い。ティアでは実用的に
-- 絞れない(stable=7 / unstable=315)ので、減らすなら明示リスト ts.install { "lua", ... } に。
ts.install("all")

-- 旧 highlight = { enable = true } / indent = { enable = true } 相当。
-- パーサが存在する FileType でのみ highlight と(実験的)indent を有効化する。
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        -- パーサ未導入の FileType では vim.treesitter.start() が失敗するため pcall。
        if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})
