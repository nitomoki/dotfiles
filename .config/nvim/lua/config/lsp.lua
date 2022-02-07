local utils = require'utils'
utils.map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
utils.map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
utils.map('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
utils.map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
utils.map('n', 'gr', '<cmd>lua vim.lsp.buf.reference()<CR>')


require'lspconfig'.clangd.setup{
    cmd = {"/home/delta/.local/share/nvim/lsp_servers/clangd/clangd/bin/clangd"},
}
require'lspconfig'.pylsp.setup{}
require'lspconfig'.hls.setup{}
require'lspconfig'.texlab.setup{}
--require'lspconfig'.omnisharp.setup{}


-- sumeko_lua
local system_name
if vim.fn.has("mac") == 1 then
  system_name = "macOS"
elseif vim.fn.has("unix") == 1 then
  system_name = "Linux"
elseif vim.fn.has('win32') == 1 then
  system_name = "Windows"
else
  print("Unsupported system for sumneko")
end

-- set the path to the sumneko installation; if you previously installed via the now deprecated :LspInstall, use
-- local sumneko_root_path = vim.fn.stdpath('cache')..'/lspconfig/sumneko_lua/lua-language-server'
local sumneko_binary
if system_name == "Linux" then
    sumneko_binary = vim.fn.stdpath('cache').."/../../.local/share/nvim/lsp_servers/sumneko_lua/extension/server/bin/lua-language-server"
end

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require'lspconfig'.sumneko_lua.setup {
    cmd = {sumneko_binary},
  -- cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
  settings = {
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
  },
}
