-- ── Workaround: nvim 0.12-dev の vim.fs.find が入れ子 root_markers 未対応 ──
-- nvim-lspconfig は nvim>=0.11.3 向けに入れ子形式の root_markers
-- ({ {".luarc.json", ...}, {...}, {".git"} }) を渡すが、このビルドの
-- vim.fs.find は入れ子テーブルを展開できず joinpath の concat でエラーになり、
-- lua_ls / deno / eslint / ts_ls / jdtls など全 LSP の起動に失敗する。
-- ビルドが入れ子未対応のときだけ vim.fs.root をラップして markers を平坦化する。
-- nvim 本体が修正されれば probe が成功し、このパッチは適用されない（将来削除可）。
if not pcall(vim.fs.root, vim.fn.getcwd(), { { ".git" } }) then
    local orig_fs_root = vim.fs.root
    vim.fs.root = function(source, marker)
        if type(marker) == "table" then
            local flat = {}
            for _, m in ipairs(marker) do
                if type(m) == "table" then
                    for _, s in ipairs(m) do
                        flat[#flat + 1] = s
                    end
                else
                    flat[#flat + 1] = m
                end
            end
            marker = flat
        end
        return orig_fs_root(source, marker)
    end
end

local server_opts = {
    ["lua_ls"] = function(opts)
        local runtime_path = vim.split(package.path, ";")
        table.insert(runtime_path, "lua/?.lua")
        table.insert(runtime_path, "lua/?/init.lua")
        opts.settings = {
            Lua = {
                runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = "LuaJIT",
                    -- Setup your lua path
                    path = runtime_path,
                },
                diagnostics = {
                    globals = {
                        -- Get the language server to recognize the `vim` global
                        "vim",
                        -- plenary
                        "describe",
                        "it",
                        "before_each",
                    },
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                    enable = false,
                },
            },
        }
    end,
}

local mason = require "mason"
mason.setup {
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        },
    },
}

-- LSP keymaps (attach時に設定)
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local bufopts = { silent = true, buffer = ev.buf }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
        vim.keymap.set("n", "gl", vim.diagnostic.open_float, bufopts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
    end,
})

-- サーバーごとの設定を vim.lsp.config() で登録
for name, configure in pairs(server_opts) do
    local opts = {}
    configure(opts)
    vim.lsp.config(name, opts)
end

-- mason-lspconfig (automatic_enable がデフォルトで有効)
require("mason-lspconfig").setup {}

local null_ls = require "null-ls"
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup {
    sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,
        null_ls.builtins.formatting.clang_format,
        null_ls.builtins.formatting.prettier,
    },
    on_attach = function(client, bufnr)
        if client:supports_method "textDocument/formatting" then
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
require("mason-null-ls").setup {
    ensure_installed = nil,
    automatic_installation = true,
}
