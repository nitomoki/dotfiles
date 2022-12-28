--local lsp_installer = require "nvim-lsp-installer"
--local k_opts = { noremap = true, silent = true }
--vim.keymap.set("n", "gD", vim.lsp.buf.declaration, k_opts)
--vim.keymap.set("n", "gd", vim.lsp.buf.definition, k_opts)
--vim.keymap.set("n", "K", vim.lsp.buf.hover, k_opts)
--vim.keymap.set("n", "gi", vim.lsp.buf.implementation, k_opts)
--vim.keymap.set("n", "gr", vim.lsp.buf.references, k_opts)
local server_opts = {
    ["sumneko_lua"] = function(opts)
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
                        "use", -- Packer use keyword
                        -- awesome lua config
                        "awesome",
                        "client",
                        "root",
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
