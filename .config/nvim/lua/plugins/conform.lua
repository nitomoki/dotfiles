-- フォーマット専用プラグイン。
-- メンテが現状維持モードの none-ls.nvim から移行した（旧 null-ls 系）。
-- フォーマッタのバイナリは lsp/config.lua の mason-tool-installer で導入される。
return {
    "stevearc/conform.nvim",
    lazy = true,
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>f",
            function()
                require("conform").format { async = true, lsp_format = "fallback" }
            end,
            mode = { "n", "v" },
            desc = "Format buffer",
        },
    },
    opts = {
        -- ファイルタイプごとのフォーマッタ。
        -- 同一行に複数並べると並び順に逐次実行される（例: isort → black）。
        formatters_by_ft = {
            lua = { "stylua" },
            python = { "isort", "black" },
            c = { "clang_format" },
            cpp = { "clang_format" },
            objc = { "clang_format" },
            objcpp = { "clang_format" },
            cuda = { "clang_format" },
            proto = { "clang_format" },
            javascript = { "prettier" },
            javascriptreact = { "prettier" },
            typescript = { "prettier" },
            typescriptreact = { "prettier" },
            vue = { "prettier" },
            css = { "prettier" },
            scss = { "prettier" },
            less = { "prettier" },
            html = { "prettier" },
            json = { "prettier" },
            jsonc = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            graphql = { "prettier" },
        },
        -- 保存時フォーマット。conform にフォーマッタが無いファイルタイプは
        -- LSP のフォーマット機能にフォールバックする（旧 null_ls 相当の挙動を維持）。
        format_on_save = {
            timeout_ms = 3000,
            lsp_format = "fallback",
        },
    },
    config = function(_, opts)
        -- ── Workaround: nvim 0.12-dev のうち vim.text.diff 追加前のビルド対応 ──
        -- conform は has('nvim-0.12') が真なら vim.text.diff を呼ぶが、この
        -- ビルドは nvim-0.12 を名乗りつつ vim.text.diff 未追加で nil エラーになる。
        -- 同シグネチャの旧 vim.diff で代替する。nvim 本体が追加すれば適用されない。
        if vim.fn.has "nvim-0.12" == 1 and not (vim.text and vim.text.diff) then
            vim.text = vim.text or {}
            vim.text.diff = vim.diff
        end
        require("conform").setup(opts)
    end,
}
