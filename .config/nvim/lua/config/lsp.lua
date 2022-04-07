local lsp_installer = require'nvim-lsp-installer'
local k_opts = {noremap = true, silent = true}
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,    k_opts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition,     k_opts)
vim.keymap.set('n', 'K',  vim.lsp.buf.hover,          k_opts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, k_opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references,     k_opts)

local server_opts  = {
    ["sumneko_lua"] = function (opts)
        local runtime_path = vim.split(package.path, ';')
        table.insert(runtime_path, "lua/?.lua")
        table.insert(runtime_path, "lua/?/init.lua")
        opts.settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
              -- Setup your lua path
              path = runtime_path,
            },
            diagnostics = {
              globals = {
                  -- Get the language server to recognize the `vim` global
                  'vim',
                  'use', -- Packer use keyword
                  -- awesome lua config
                  'awesome',
                  'client',
                  'root',
                  },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
              enable = false,
            },
          },
        }
        opts.commands = {
            Format = {
                function()
                    require'stylua-nvim'.format_file()
                end
            }
        }
    end
}


lsp_installer.on_server_ready(function(server)
    local opts = {}
    if server_opts[server.name] then
        server_opts[server.name](opts)
    end
    server:setup(opts)
end)


