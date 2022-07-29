local cmd = vim.cmd

-- require'config.japanesemode'.setup()
require "options"
require "keymaps"
require "plugins"
require "augroups"
--require "formatter"
cmd [[PackerInstall]]
cmd [[colorscheme sonokai]]
