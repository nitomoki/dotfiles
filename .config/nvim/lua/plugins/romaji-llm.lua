-- ローマ字を LLM(Haiku) で漢字仮名交じりに変換する入力支援。
-- ローカル開発: ~/NeovimPlugins/romaji-llm.nvim (lazy の dev 機構)。
--
-- 設定はすべて setup{} で上書きできる(既定値はプラグイン側)。
-- 上書き可能な項目の一覧は README の「設定」を参照。
local _, dev = require("utils").local_plugins_path()

return {
    "nitomoki/romaji-llm.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    dev = dev,
    -- 既定では動かない。コマンド実行時に初めてロード/有効化する(オプトイン)。
    cmd = {
        "RomajiLLMEnable",
        "RomajiLLMDisable",
        "RomajiLLMToggle",
        "RomajiConvert",
        "RomajiLLMLog",
        "RomajiLLMDebug",
        "RomajiLLMDict",
        "RomajiLLMDictEdit",
    },
    config = function()
        require("romaji_llm").setup {
            debug = true, -- API 送受信をログ(:RomajiLLMLog)。不要なら外す。
        }
    end,
}
