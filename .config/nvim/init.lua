local cmd = vim.cmd
local utils = require('utils')

require'config.japanesemode'.setup()
require'options'
require'keymaps'
require'plugins'
cmd('colorscheme sonokai')

utils.create_augroup({
    {'BufWritePost', 'plugins.lua', 'PackerCompile'}
}, 'AutoPackerCompile')

utils.create_augroup({
    {'BufNewFile,BufRead', '*.launch', 'set', 'filetype=xml'}
}, 'BufE')

