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

utils.create_augroup({
    {'BufWritePost', 'plugins.lua', 'PackerCompile'}
}, 'AutoPackerCompile')

utils.create_augroup({
    {'BufNewFile,BufRead', '*.launch', 'set', 'filetype=xml'}
}, 'BufE')

