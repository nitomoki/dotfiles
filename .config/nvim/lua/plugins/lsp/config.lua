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
                        -- awesome lua config
                        "awesome",
                        "client",
                        "root",
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

require("neodev").setup {}

local nvim_lsp = require "lspconfig"
require("mason-lspconfig").setup_handlers {
    function(server_name)
        local opts = {}
        opts.on_attach = function(_, bufnr)
            local bufopts = { silent = true, buffer = bufnr }
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
        end
        if server_opts[server_name] then
            server_opts[server_name](opts)
        end
        --server:setup(opts)
        nvim_lsp[server_name].setup(opts)
    end,
}

local null_ls = require "null-ls"
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup {
    sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,
        null_ls.builtins.formatting.clang_format,
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
require("mason-null-ls").setup {
    ensure_installed = nil,
    automatic_installation = true,
}
