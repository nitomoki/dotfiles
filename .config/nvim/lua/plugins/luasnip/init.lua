return {
    "L3MON4D3/LuaSnip",
    lazy = true,
    -- jsregexp をビルドして変数/プレースホルダ変換を有効化（checkhealth 警告解消）
    build = "make install_jsregexp",
    config = function()
        require "plugins.luasnip.config"
    end,
}
