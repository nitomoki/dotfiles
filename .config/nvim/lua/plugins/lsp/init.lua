return {
    "neovim/nvim-lspconfig",
    lazy = true,
    event = "BufReadPost",
    dependencies = {
        { "williamboman/mason.nvim" },
        { "williamboman/mason-lspconfig.nvim" },
        {
            "jose-elias-alvarez/null-ls.nvim",
            dependencies = {
                "nvim-lua/plenary.nvim",
            },
        },
        { "folke/neodev.nvim" },
    },
    config = function()
        require "plugins.lsp.config"
        local null_ls = require "null-ls"
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
        null_ls.setup {
            sources = {
                null_ls.builtins.formatting.stylua,
                null_ls.builtins.formatting.black,
                null_ls.builtins.formatting.isort,
                null_ls.builtins.diagnostics.eslint,
            },
            on_attach = function(client, bufnr)
                if client.supports_method "textDocument/formatting" then
                    vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = augroup,
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format { bufnr = bufnr }
                        end,
                    })
                end
            end,
        }
    end,
}
