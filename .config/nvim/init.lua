local o = vim.o
local w = vim.wo
local b = vim.bo
local g = vim.g
local fn = vim.fn
local cmd = vim.cmd
local utils = require('utils')

require'nitom.japanesemode'.setup()
require'options'
require'keymaps'
require'plugins'
--require'nitom.dein'
--require'nitom.nitomterm'.setup()
--require'nvim-treesitter.configs'.setup {
--  highlight = {
--    enable = true,
--    disable = {
--      'ruby',
--      'toml',
--      'c_sharp',
--      'vue',
--    }
--  },
--  ensure_installed = 'maintained',
--}
utils.create_augroup({
    {'BufWritePost', 'plugins.lua', 'PackerCompile'}
}, 'AutoPackerCompile')

utils.create_augroup({
    {'BufNewFile,BufRead', '*.launch', 'set', 'filetype=xml'}
}, 'BufE')



