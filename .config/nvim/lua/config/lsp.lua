local utils = require'utils'
local lsp_installer = require'nvim-lsp-installer'
utils.map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
utils.map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
utils.map('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
utils.map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
utils.map('n', 'gr', '<cmd>lua vim.lsp.buf.reference()<CR>')

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
    end
}


lsp_installer.on_server_ready(function(server)
    local opts = {}
    if server_opts[server.name] then
        server_opts[server.name](opts)
    end
    server:setup(opts)
end)


