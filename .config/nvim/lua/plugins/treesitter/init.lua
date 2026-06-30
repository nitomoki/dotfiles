return {
    "nvim-treesitter/nvim-treesitter",
    -- 完全リライトされた main ブランチを使用する。GitHub のデフォルトブランチが
    -- master から main へ変わった経緯があるため、意図を明示して固定する。
    branch = "main",
    -- main は lazy-load 非対応 (:h nvim-treesitter)。必ず lazy=false で読み込む。
    lazy = false,
    -- パーサ更新。旧 install.update{ with_sync = true } は :TSUpdate に置き換え。
    build = ":TSUpdate",
    config = function()
        require "plugins.treesitter.config"
    end,
}
